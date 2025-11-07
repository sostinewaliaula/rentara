const express = require('express');
const { body, validationResult } = require('express-validator');
const prisma = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');
const { sendNotification } = require('../services/smsService');

const router = express.Router();

router.use(authenticate);

/**
 * @route   GET /api/units
 * @desc    Get all units (filtered by role)
 * @access  Private
 */
router.get('/', async (req, res, next) => {
  try {
    let units;

    if (req.user.role === 'ADMIN') {
      units = await prisma.unit.findMany({
        include: {
          property: {
            select: {
              id: true,
              name: true,
              location: true,
            },
          },
          tenant: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      });
    } else if (req.user.role === 'CARETAKER') {
      // Get units from properties assigned to caretaker
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
          propertyId: {
            in: properties.map(p => p.id),
          },
        },
        include: {
          property: {
            select: {
              id: true,
              name: true,
              location: true,
            },
          },
          tenant: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      });
    } else {
      // Tenant - only their units
      units = await prisma.unit.findMany({
        where: { tenantId: req.user.id },
        include: {
          property: {
            select: {
              id: true,
              name: true,
              location: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      });
    }

    res.json({ units });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/units/:id
 * @desc    Get unit by ID
 * @access  Private
 */
router.get('/:id', async (req, res, next) => {
  try {
    const unit = await prisma.unit.findUnique({
      where: { id: req.params.id },
      include: {
        property: true,
        tenant: {
          select: {
            id: true,
            name: true,
            phone: true,
            email: true,
          },
        },
        payments: {
          orderBy: [{ year: 'desc' }, { month: 'desc' }],
          take: 12,
        },
        maintenance: {
          orderBy: { createdAt: 'desc' },
          take: 10,
        },
      },
    });

    if (!unit) {
      return res.status(404).json({ error: 'Unit not found' });
    }

    // Check access
    if (req.user.role === 'TENANT' && unit.tenantId !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (req.user.role === 'CARETAKER') {
      const property = await prisma.property.findFirst({
        where: {
          id: unit.propertyId,
          caretakers: {
            some: {
              userId: req.user.id,
            },
          },
        },
      });

      if (!property) {
        return res.status(403).json({ error: 'Access denied' });
      }
    }

    res.json({ unit });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/units
 * @desc    Create new unit
 * @access  Private (Admin only)
 */
router.post(
  '/',
  authorize('ADMIN'),
  [
    body('propertyId').notEmpty().withMessage('Property ID is required'),
    body('name').trim().notEmpty().withMessage('Unit name is required'),
    body('rentAmount').isFloat({ min: 0 }).withMessage('Valid rent amount is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { propertyId, name, rentAmount, description, images, status } = req.body;

      const unit = await prisma.unit.create({
        data: {
          propertyId,
          name,
          rentAmount: parseFloat(rentAmount),
          description,
          images: images ? (Array.isArray(images) ? images : [images]) : [],
          status: status || 'VACANT',
        },
        include: {
          property: {
            select: {
              id: true,
              name: true,
            },
          },
        },
      });

      res.status(201).json({
        message: 'Unit created successfully',
        unit,
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   PUT /api/units/:id
 * @desc    Update unit
 * @access  Private (Admin only)
 */
router.put(
  '/:id',
  authorize('ADMIN'),
  async (req, res, next) => {
    try {
      const unit = await prisma.unit.update({
        where: { id: req.params.id },
        data: req.body,
        include: {
          property: {
            select: {
              id: true,
              name: true,
            },
          },
          tenant: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
        },
      });

      res.json({
        message: 'Unit updated successfully',
        unit,
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   POST /api/units/:id/assign-tenant
 * @desc    Assign tenant to unit
 * @access  Private (Admin only)
 */
router.post(
  '/:id/assign-tenant',
  authorize('ADMIN'),
  [
    body('tenantId').notEmpty().withMessage('Tenant ID is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { tenantId } = req.body;

      // Verify user is a tenant
      const tenant = await prisma.user.findUnique({
        where: { id: tenantId },
      });

      if (!tenant || tenant.role !== 'TENANT') {
        return res.status(400).json({ error: 'User must be a tenant' });
      }

      const unit = await prisma.unit.update({
        where: { id: req.params.id },
        data: {
          tenantId,
          status: 'OCCUPIED',
        },
        include: {
          property: true,
          tenant: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
        },
      });

      // Notify tenant
      await sendNotification(
        tenantId,
        'Unit Assignment',
        `You have been assigned to ${unit.name} at ${unit.property.name}. Rent: KES ${unit.rentAmount}/month.`,
        'SMS'
      );

      res.json({
        message: 'Tenant assigned successfully',
        unit,
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   POST /api/units/:id/vacate
 * @desc    Vacate unit (remove tenant)
 * @access  Private (Admin only)
 */
router.post(
  '/:id/vacate',
  authorize('ADMIN'),
  async (req, res, next) => {
    try {
      const unit = await prisma.unit.findUnique({
        where: { id: req.params.id },
        include: { tenant: true },
      });

      if (!unit) {
        return res.status(404).json({ error: 'Unit not found' });
      }

      const tenantId = unit.tenantId;

      const updatedUnit = await prisma.unit.update({
        where: { id: req.params.id },
        data: {
          tenantId: null,
          status: 'VACANT',
        },
      });

      // Notify tenant if they existed
      if (tenantId) {
        await sendNotification(
          tenantId,
          'Unit Vacated',
          `You have been removed from ${unit.name} at ${unit.property.name}.`,
          'SMS'
        );
      }

      res.json({
        message: 'Unit vacated successfully',
        unit: updatedUnit,
      });
    } catch (error) {
      next(error);
    }
  }
);

module.exports = router;



