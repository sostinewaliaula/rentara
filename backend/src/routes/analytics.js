const express = require('express');
const prisma = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);
router.use(authorize('ADMIN', 'CARETAKER'));

/**
 * @route   GET /api/analytics/dashboard
 * @desc    Get dashboard analytics
 * @access  Private (Admin, Caretaker)
 */
router.get('/dashboard', async (req, res, next) => {
  try {
    const currentMonth = new Date().getMonth() + 1;
    const currentYear = new Date().getFullYear();

    // Get properties based on role
    let properties;
    if (req.user.role === 'ADMIN') {
      properties = await prisma.property.findMany({
        select: { id: true },
      });
    } else {
      // Caretaker
      const assignedProperties = await prisma.property.findMany({
        where: {
          caretakers: {
            some: {
              userId: req.user.id,
            },
          },
        },
        select: { id: true },
      });
      properties = assignedProperties;
    }

    const propertyIds = properties.map(p => p.id);

    // Get all units
    const allUnits = await prisma.unit.findMany({
      where: {
        propertyId: { in: propertyIds },
      },
      include: {
        tenant: {
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
        maintenance: {
          where: {
            createdAt: {
              gte: new Date(currentYear, 0, 1),
            },
          },
        },
      },
    });

    // Calculate statistics
    const totalUnits = allUnits.length;
    const occupiedUnits = allUnits.filter(u => u.status === 'OCCUPIED').length;
    const vacantUnits = allUnits.filter(u => u.status === 'VACANT').length;
    const maintenanceUnits = allUnits.filter(u => u.status === 'MAINTENANCE').length;

    // Revenue calculations
    const totalRentAmount = allUnits.reduce((sum, unit) => sum + unit.rentAmount, 0);
    const expectedMonthlyRevenue = occupiedUnits * (totalRentAmount / totalUnits || 0);

    // Get payments for current year
    const payments = await prisma.payment.findMany({
      where: {
        unitId: { in: allUnits.map(u => u.id) },
        year: currentYear,
        status: 'COMPLETED',
      },
    });

    const totalCollected = payments.reduce((sum, p) => sum + p.amount, 0);
    const monthlyRevenue = payments
      .filter(p => p.month === currentMonth)
      .reduce((sum, p) => sum + p.amount, 0);

    // Calculate arrears
    const arrears = allUnits
      .filter(u => u.status === 'OCCUPIED')
      .map(unit => {
        const paidMonths = unit.payments
          .filter(p => p.status === 'COMPLETED')
          .map(p => p.month);
        
        const unpaidMonths = [];
        for (let month = 1; month <= currentMonth; month++) {
          if (!paidMonths.includes(month)) {
            unpaidMonths.push(month);
          }
        }

        return unpaidMonths.length * unit.rentAmount;
      })
      .reduce((sum, amount) => sum + amount, 0);

    // Maintenance statistics
    const allMaintenance = await prisma.maintenance.findMany({
      where: {
        unitId: { in: allUnits.map(u => u.id) },
        createdAt: {
          gte: new Date(currentYear, 0, 1),
        },
      },
    });

    const pendingMaintenance = allMaintenance.filter(m => m.status === 'PENDING').length;
    const inProgressMaintenance = allMaintenance.filter(m => m.status === 'IN_PROGRESS').length;
    const resolvedMaintenance = allMaintenance.filter(m => m.status === 'RESOLVED').length;

    // Calculate average resolution time
    const resolvedMaintenanceWithTime = allMaintenance
      .filter(m => m.status === 'RESOLVED' && m.resolvedAt)
      .map(m => ({
        createdAt: m.createdAt,
        resolvedAt: m.resolvedAt,
        days: Math.floor((m.resolvedAt - m.createdAt) / (1000 * 60 * 60 * 24)),
      }));

    const avgResolutionDays = resolvedMaintenanceWithTime.length > 0
      ? Math.round(
          resolvedMaintenanceWithTime.reduce((sum, m) => sum + m.days, 0) /
          resolvedMaintenanceWithTime.length
        )
      : 0;

    // Monthly revenue trend (last 6 months)
    const monthlyTrend = [];
    for (let i = 5; i >= 0; i--) {
      const month = currentMonth - i;
      const year = month <= 0 ? currentYear - 1 : currentYear;
      const actualMonth = month <= 0 ? month + 12 : month;

      const monthPayments = payments.filter(
        p => p.month === actualMonth && p.year === year
      );
      const monthRevenue = monthPayments.reduce((sum, p) => sum + p.amount, 0);

      monthlyTrend.push({
        month: actualMonth,
        year,
        revenue: monthRevenue,
      });
    }

    // Occupancy rate
    const occupancyRate = totalUnits > 0 ? (occupiedUnits / totalUnits) * 100 : 0;

    res.json({
      overview: {
        totalUnits,
        occupiedUnits,
        vacantUnits,
        maintenanceUnits,
        occupancyRate: Math.round(occupancyRate * 100) / 100,
      },
      revenue: {
        totalCollected,
        monthlyRevenue,
        expectedMonthlyRevenue: Math.round(expectedMonthlyRevenue),
        arrears: Math.round(arrears),
        collectionRate: expectedMonthlyRevenue > 0
          ? Math.round((monthlyRevenue / expectedMonthlyRevenue) * 100)
          : 0,
      },
      maintenance: {
        pending: pendingMaintenance,
        inProgress: inProgressMaintenance,
        resolved: resolvedMaintenance,
        total: allMaintenance.length,
        avgResolutionDays,
      },
      trends: {
        monthlyRevenue: monthlyTrend,
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/analytics/properties/:id
 * @desc    Get analytics for specific property
 * @access  Private (Admin, Caretaker)
 */
router.get('/properties/:id', async (req, res, next) => {
  try {
    const property = await prisma.property.findUnique({
      where: { id: req.params.id },
      include: {
        units: {
          include: {
            tenant: {
              select: {
                id: true,
                name: true,
                phone: true,
              },
            },
            payments: {
              where: {
                year: new Date().getFullYear(),
              },
            },
          },
        },
      },
    });

    if (!property) {
      return res.status(404).json({ error: 'Property not found' });
    }

    // Check access for caretakers
    if (req.user.role === 'CARETAKER') {
      const hasAccess = await prisma.propertyCaretaker.findFirst({
        where: {
          propertyId: property.id,
          userId: req.user.id,
        },
      });

      if (!hasAccess) {
        return res.status(403).json({ error: 'Access denied' });
      }
    }

    const totalUnits = property.units.length;
    const occupiedUnits = property.units.filter(u => u.status === 'OCCUPIED').length;
    const vacantUnits = property.units.filter(u => u.status === 'VACANT').length;

    const totalRent = property.units.reduce((sum, u) => sum + u.rentAmount, 0);
    const collectedRent = property.units
      .flatMap(u => u.payments)
      .filter(p => p.status === 'COMPLETED')
      .reduce((sum, p) => sum + p.amount, 0);

    res.json({
      property: {
        id: property.id,
        name: property.name,
        location: property.location,
      },
      statistics: {
        totalUnits,
        occupiedUnits,
        vacantUnits,
        occupancyRate: totalUnits > 0 ? Math.round((occupiedUnits / totalUnits) * 100) : 0,
        totalRent,
        collectedRent,
        collectionRate: totalRent > 0 ? Math.round((collectedRent / totalRent) * 100) : 0,
      },
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;




