const express = require('express');
const prisma = require('../config/database');
const { initiateSTKPush } = require('../services/mpesaService');
const { sendSMS } = require('../services/smsService');

const router = express.Router();

/**
 * @route   POST /api/ussd
 * @desc    Handle USSD requests from Africa's Talking
 * @access  Public (called by Africa's Talking)
 */
router.post('/', async (req, res, next) => {
  try {
    const {
      phoneNumber,
      sessionId,
      serviceCode,
      text,
    } = req.body;

    // Format phone number
    const formattedPhone = phoneNumber.startsWith('0')
      ? `+254${phoneNumber.slice(1)}`
      : phoneNumber.startsWith('+')
      ? phoneNumber
      : `+${phoneNumber}`;

    // Get or create session
    let session = await prisma.uSSDSession.findUnique({
      where: { sessionId },
    });

    if (!session) {
      // Find user by phone
      const user = await prisma.user.findUnique({
        where: { phone: formattedPhone },
      });

      session = await prisma.uSSDSession.create({
        data: {
          phoneNumber: formattedPhone,
          sessionId,
          state: 'MAIN_MENU',
          data: user ? JSON.stringify({ userId: user.id, role: user.role }) : null,
        },
      });
    }

    // Parse text to determine menu level
    const textArray = text ? text.split('*') : [];
    const currentLevel = textArray.length;
    const lastInput = textArray[textArray.length - 1];

    let response = '';
    let newState = session.state;

    // Main menu
    if (currentLevel === 0 || lastInput === '0') {
      response = `CON Welcome to Rentara\n`;
      response += `1. Check Rent Balance\n`;
      response += `2. Pay Rent\n`;
      response += `3. Submit Maintenance Request\n`;
      response += `4. View Lease Info\n`;
      newState = 'MAIN_MENU';
    } else {
      // Check if user exists
      const sessionData = session.data ? JSON.parse(session.data) : null;
      
      if (!sessionData || !sessionData.userId) {
        response = `END You are not registered. Please contact your landlord.`;
      } else {
        const userId = sessionData.userId;
        const userRole = sessionData.role;

        if (userRole !== 'TENANT') {
          response = `END USSD access is only available for tenants.`;
        } else {
          // Handle menu options
          switch (lastInput) {
            case '1': // Check Rent Balance
              response = await handleCheckBalance(userId);
              newState = 'MAIN_MENU';
              break;

            case '2': // Pay Rent
              if (currentLevel === 1) {
                response = await handlePayRentMenu(userId);
                newState = 'PAY_RENT_SELECT_UNIT';
              } else if (currentLevel === 2) {
                // Unit selected, now select month
                response = await handlePayRentSelectMonth(userId, lastInput);
                newState = 'PAY_RENT_SELECT_MONTH';
              } else if (currentLevel === 3) {
                // Month selected, initiate payment
                const unitIndex = parseInt(textArray[1]) - 1;
                const monthIndex = parseInt(lastInput) - 1;
                response = await handlePayRentConfirm(userId, unitIndex, monthIndex, sessionId);
                newState = 'MAIN_MENU';
              }
              break;

            case '3': // Submit Maintenance Request
              if (currentLevel === 1) {
                response = await handleMaintenanceMenu(userId);
                newState = 'MAINTENANCE_SELECT_UNIT';
              } else if (currentLevel === 2) {
                // Unit selected, prompt for description
                response = `CON Enter maintenance description:\n`;
                newState = 'MAINTENANCE_ENTER_DESC';
              } else if (currentLevel >= 3) {
                // Description entered
                const unitIndex = parseInt(textArray[1]) - 1;
                const description = textArray.slice(2).join(' ');
                response = await handleMaintenanceSubmit(userId, unitIndex, description);
                newState = 'MAIN_MENU';
              }
              break;

            case '4': // View Lease Info
              response = await handleLeaseInfo(userId);
              newState = 'MAIN_MENU';
              break;

            default:
              response = `END Invalid option. Please try again.`;
          }
        }
      }
    }

    // Update session
    await prisma.uSSDSession.update({
      where: { sessionId },
      data: {
        state: newState,
        lastAction: lastInput,
        updatedAt: new Date(),
      },
    });

    res.set('Content-Type', 'text/plain');
    res.send(response);
  } catch (error) {
    console.error('USSD Error:', error);
    res.set('Content-Type', 'text/plain');
    res.send('END An error occurred. Please try again later.');
  }
});

// Helper functions
async function handleCheckBalance(userId) {
  const units = await prisma.unit.findMany({
    where: { tenantId: userId },
    include: {
      property: true,
      payments: {
        where: {
          year: new Date().getFullYear(),
        },
      },
    },
  });

  if (units.length === 0) {
    return `END You have no assigned units.`;
  }

  let response = `CON Your Rent Balance:\n\n`;
  
  for (const unit of units) {
    const currentMonth = new Date().getMonth() + 1;
    const paidMonths = unit.payments
      .filter(p => p.status === 'COMPLETED')
      .map(p => p.month);
    
    const unpaidMonths = [];
    for (let month = 1; month <= currentMonth; month++) {
      if (!paidMonths.includes(month)) {
        unpaidMonths.push(month);
      }
    }

    const totalArrears = unpaidMonths.length * unit.rentAmount;
    
    response += `${unit.name}:\n`;
    response += `Rent: KES ${unit.rentAmount}\n`;
    response += `Unpaid: ${unpaidMonths.length} months\n`;
    response += `Total: KES ${totalArrears}\n\n`;
  }

  response += `0. Back`;
  return response;
}

async function handlePayRentMenu(userId) {
  const units = await prisma.unit.findMany({
    where: { tenantId: userId },
    include: { property: true },
  });

  if (units.length === 0) {
    return `END You have no assigned units.`;
  }

  let response = `CON Select Unit:\n`;
  units.forEach((unit, index) => {
    response += `${index + 1}. ${unit.name} (KES ${unit.rentAmount})\n`;
  });
  response += `0. Back`;

  return response;
}

async function handlePayRentSelectMonth(userId, unitIndex) {
  const units = await prisma.unit.findMany({
    where: { tenantId: userId },
  });

  if (!units[parseInt(unitIndex) - 1]) {
    return `END Invalid unit selection.`;
  }

  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  let response = `CON Select Month:\n`;
  const currentMonth = new Date().getMonth() + 1;
  
  for (let i = 1; i <= currentMonth; i++) {
    response += `${i}. ${months[i - 1]}\n`;
  }
  response += `0. Back`;

  return response;
}

async function handlePayRentConfirm(userId, unitIndex, monthIndex, sessionId) {
  try {
    const units = await prisma.unit.findMany({
      where: { tenantId: userId },
      include: { property: true },
    });

    const unit = units[unitIndex];
    if (!unit) {
      return `END Invalid unit selection.`;
    }

    const month = monthIndex + 1;
    const year = new Date().getFullYear();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    // Check if payment exists
    const existingPayment = await prisma.payment.findUnique({
      where: {
        tenantId_unitId_month_year: {
          tenantId: userId,
          unitId: unit.id,
          month,
          year,
        },
      },
    });

    if (existingPayment && existingPayment.status === 'COMPLETED') {
      return `END Payment for ${months[monthIndex]} already completed.`;
    }

    // Create or update payment
    const payment = await prisma.payment.upsert({
      where: existingPayment
        ? {
            tenantId_unitId_month_year: {
              tenantId: userId,
              unitId: unit.id,
              month,
              year,
            },
          }
        : undefined,
      create: {
        tenantId: userId,
        unitId: unit.id,
        amount: unit.rentAmount,
        month,
        year,
        status: 'PENDING',
      },
      update: {
        status: 'PENDING',
      },
    });

    // Get user phone
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { phone: true },
    });

    // Initiate STK push
    const accountReference = `RENT-${unit.id}-${month}-${year}`;
    const stkResult = await initiateSTKPush(
      user.phone,
      unit.rentAmount,
      accountReference,
      `Rent payment for ${unit.name} - ${months[monthIndex]}`
    );

    // Update payment with checkout request ID
    await prisma.payment.update({
      where: { id: payment.id },
      data: {
        transactionId: stkResult.checkoutRequestId,
      },
    });

    return `END Payment initiated. Please complete on your phone. You will receive an SMS confirmation.`;
  } catch (error) {
    console.error('Error initiating payment:', error);
    return `END Payment failed. Please try again or contact support.`;
  }
}

async function handleMaintenanceMenu(userId) {
  const units = await prisma.unit.findMany({
    where: { tenantId: userId },
    include: { property: true },
  });

  if (units.length === 0) {
    return `END You have no assigned units.`;
  }

  let response = `CON Select Unit:\n`;
  units.forEach((unit, index) => {
    response += `${index + 1}. ${unit.name}\n`;
  });
  response += `0. Back`;

  return response;
}

async function handleMaintenanceSubmit(userId, unitIndex, description) {
  try {
    const units = await prisma.unit.findMany({
      where: { tenantId: userId },
      include: { property: true },
    });

    const unit = units[unitIndex];
    if (!unit) {
      return `END Invalid unit selection.`;
    }

    if (!description || description.trim().length < 5) {
      return `END Description too short. Please provide more details.`;
    }

    await prisma.maintenance.create({
      data: {
        unitId: unit.id,
        description: description.trim(),
        createdById: userId,
        status: 'PENDING',
      },
    });

    return `END Maintenance request submitted successfully. You will receive updates via SMS.`;
  } catch (error) {
    console.error('Error submitting maintenance:', error);
    return `END Failed to submit request. Please try again.`;
  }
}

async function handleLeaseInfo(userId) {
  const units = await prisma.unit.findMany({
    where: { tenantId: userId },
    include: { property: true },
  });

  if (units.length === 0) {
    return `END You have no assigned units.`;
  }

  let response = `CON Lease Information:\n\n`;
  units.forEach((unit, index) => {
    response += `${index + 1}. ${unit.name}\n`;
    response += `Property: ${unit.property.name}\n`;
    response += `Location: ${unit.property.location}\n`;
    response += `Rent: KES ${unit.rentAmount}/month\n\n`;
  });
  response += `0. Back`;

  return response;
}

module.exports = router;




