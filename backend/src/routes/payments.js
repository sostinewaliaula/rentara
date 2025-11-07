const express = require('express');
const { body, validationResult } = require('express-validator');
const prisma = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');
const { initiateSTKPush } = require('../services/mpesaService');
const { sendNotification } = require('../services/smsService');

const router = express.Router();

router.use(authenticate);

/**
 * @route   GET /api/payments
 * @desc    Get payments (filtered by role)
 * @access  Private
 */
router.get('/', async (req, res, next) => {
  try {
    let payments;

    if (req.user.role === 'ADMIN') {
      payments = await prisma.payment.findMany({
        include: {
          tenant: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
          unit: {
            include: {
              property: {
                select: {
                  id: true,
                  name: true,
                },
              },
            },
          },
        },
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
      });
    } else if (req.user.role === 'CARETAKER') {
      // Get payments for units in assigned properties
      const properties = await prisma.property.findMany({
        where: {
          caretakers: {
            some: {
              userId: req.user.id,
            },
          },
        },
        select: { id: true },
      });

      const units = await prisma.unit.findMany({
        where: {
          propertyId: {
            in: properties.map(p => p.id),
          },
        },
        select: { id: true },
      });

      payments = await prisma.payment.findMany({
        where: {
          unitId: {
            in: units.map(u => u.id),
          },
        },
        include: {
          tenant: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
          unit: {
            include: {
              property: {
                select: {
                  id: true,
                  name: true,
                },
              },
            },
          },
        },
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
      });
    } else {
      // Tenant - only their payments
      payments = await prisma.payment.findMany({
        where: { tenantId: req.user.id },
        include: {
          unit: {
            include: {
              property: {
                select: {
                  id: true,
                  name: true,
                },
              },
            },
          },
        },
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
      });
    }

    res.json({ payments });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/payments/:id
 * @desc    Get payment by ID
 * @access  Private
 */
router.get('/:id', async (req, res, next) => {
  try {
    const payment = await prisma.payment.findUnique({
      where: { id: req.params.id },
      include: {
        tenant: {
          select: {
            id: true,
            name: true,
            phone: true,
          },
        },
        unit: {
          include: {
            property: true,
          },
        },
      },
    });

    if (!payment) {
      return res.status(404).json({ error: 'Payment not found' });
    }

    // Check access
    if (req.user.role === 'TENANT' && payment.tenantId !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ payment });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/payments/initiate
 * @desc    Initiate M-Pesa payment
 * @access  Private (Tenant only)
 */
router.post(
  '/initiate',
  authorize('TENANT'),
  [
    body('unitId').notEmpty().withMessage('Unit ID is required'),
    body('month').isInt({ min: 1, max: 12 }).withMessage('Valid month is required'),
    body('year').isInt({ min: 2020 }).withMessage('Valid year is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { unitId, month, year } = req.body;

      // Get unit and verify tenant
      const unit = await prisma.unit.findUnique({
        where: { id: unitId },
        include: {
          property: true,
        },
      });

      if (!unit) {
        return res.status(404).json({ error: 'Unit not found' });
      }

      if (unit.tenantId !== req.user.id) {
        return res.status(403).json({ error: 'You are not assigned to this unit' });
      }

      // Check if payment already exists
      const existingPayment = await prisma.payment.findUnique({
        where: {
          tenantId_unitId_month_year: {
            tenantId: req.user.id,
            unitId,
            month: parseInt(month),
            year: parseInt(year),
          },
        },
      });

      if (existingPayment && existingPayment.status === 'COMPLETED') {
        return res.status(400).json({ error: 'Payment for this period already completed' });
      }

      // Create or update payment record
      const payment = await prisma.payment.upsert({
        where: existingPayment
          ? {
              tenantId_unitId_month_year: {
                tenantId: req.user.id,
                unitId,
                month: parseInt(month),
                year: parseInt(year),
              },
            }
          : undefined,
        create: {
          tenantId: req.user.id,
          unitId,
          amount: unit.rentAmount,
          month: parseInt(month),
          year: parseInt(year),
          status: 'PENDING',
        },
        update: {
          status: 'PENDING',
        },
      });

      // Initiate STK push
      const accountReference = `RENT-${unitId}-${month}-${year}`;
      const transactionDesc = `Rent payment for ${unit.name}`;

      const stkResult = await initiateSTKPush(
        req.user.phone,
        unit.rentAmount,
        accountReference,
        transactionDesc
      );

      // Update payment with checkout request ID
      await prisma.payment.update({
        where: { id: payment.id },
        data: {
          transactionId: stkResult.checkoutRequestId,
        },
      });

      res.json({
        message: 'Payment initiated. Please complete on your phone.',
        checkoutRequestId: stkResult.checkoutRequestId,
        customerMessage: stkResult.customerMessage,
        payment,
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   POST /api/payments/mpesa-callback
 * @desc    M-Pesa callback webhook
 * @access  Public (called by Safaricom)
 */
router.post('/mpesa-callback', async (req, res, next) => {
  try {
    const { Body } = req.body;
    const stkCallback = Body.stkCallback;

    if (!stkCallback) {
      return res.status(400).json({ error: 'Invalid callback data' });
    }

    const checkoutRequestId = stkCallback.CheckoutRequestID;
    const resultCode = stkCallback.ResultCode;
    const resultDesc = stkCallback.ResultDesc;

    // Find payment by checkout request ID
    const payment = await prisma.payment.findFirst({
      where: { transactionId: checkoutRequestId },
      include: {
        tenant: true,
        unit: {
          include: {
            property: true,
          },
        },
      },
    });

    if (!payment) {
      console.error('Payment not found for checkout request:', checkoutRequestId);
      return res.status(404).json({ error: 'Payment not found' });
    }

    if (resultCode === 0) {
      // Payment successful
      const callbackMetadata = stkCallback.CallbackMetadata;
      const items = callbackMetadata?.Item || [];

      const mpesaReceipt = items.find(item => item.Name === 'MpesaReceiptNumber')?.Value;
      const transactionDate = items.find(item => item.Name === 'TransactionDate')?.Value;
      const phoneNumber = items.find(item => item.Name === 'PhoneNumber')?.Value;

      await prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: 'COMPLETED',
          mpesaReceipt,
          paidAt: new Date(),
        },
      });

      // Send confirmation SMS
      await sendNotification(
        payment.tenantId,
        'Payment Confirmed',
        `Your rent payment of KES ${payment.amount} for ${payment.unit.name} has been confirmed. Receipt: ${mpesaReceipt}`,
        'SMS'
      );
    } else {
      // Payment failed
      await prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: 'FAILED',
        },
      });

      await sendNotification(
        payment.tenantId,
        'Payment Failed',
        `Your rent payment for ${payment.unit.name} failed. Please try again.`,
        'SMS'
      );
    }

    res.json({ message: 'Callback processed' });
  } catch (error) {
    console.error('Error processing M-Pesa callback:', error);
    next(error);
  }
});

/**
 * @route   GET /api/payments/arrears
 * @desc    Get rent arrears report
 * @access  Private (Admin, Caretaker)
 */
router.get('/arrears', authorize('ADMIN', 'CARETAKER'), async (req, res, next) => {
  try {
    const currentMonth = new Date().getMonth() + 1;
    const currentYear = new Date().getFullYear();

    // Get all occupied units
    let units;
    if (req.user.role === 'ADMIN') {
      units = await prisma.unit.findMany({
        where: { status: 'OCCUPIED' },
        include: {
          tenant: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
          property: {
            select: {
              id: true,
              name: true,
            },
          },
          payments: {
            where: {
              year: currentYear,
            },
          },
        },
      });
    } else {
      // Caretaker - only assigned properties
      const properties = await prisma.property.findMany({
        where: {
          caretakers: {
            some: {
              userId: req.user.id,
            },
          },
        },
        select: { id: true },
      });

      units = await prisma.unit.findMany({
        where: {
          propertyId: { in: properties.map(p => p.id) },
          status: 'OCCUPIED',
        },
        include: {
          tenant: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
          property: {
            select: {
              id: true,
              name: true,
            },
          },
          payments: {
            where: {
              year: currentYear,
            },
          },
        },
      });
    }

    // Calculate arrears
    const arrears = units.map(unit => {
      const paidMonths = unit.payments
        .filter(p => p.status === 'COMPLETED')
        .map(p => p.month);

      const monthsInArrears = [];
      for (let month = 1; month <= currentMonth; month++) {
        if (!paidMonths.includes(month)) {
          monthsInArrears.push(month);
        }
      }

      const totalArrears = monthsInArrears.length * unit.rentAmount;

      return {
        unit: {
          id: unit.id,
          name: unit.name,
          property: unit.property.name,
        },
        tenant: unit.tenant,
        rentAmount: unit.rentAmount,
        monthsInArrears,
        totalArrears,
        monthsCount: monthsInArrears.length,
      };
    }).filter(item => item.monthsCount > 0);

    res.json({ arrears });
  } catch (error) {
    next(error);
  }
});

module.exports = router;




