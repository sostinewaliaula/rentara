import express from 'express';
import { executeQuery } from '../config/database.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticate);
router.use(authorize('ADMIN', 'CARETAKER'));

const buildPropertyFilter = async (user) => {
  if (user.role === 'ADMIN') {
    return { clause: '', params: [] };
  }

  const result = await executeQuery(
    `SELECT property_id FROM property_caretakers WHERE user_id = ?`,
    [user.id]
  );

  const propertyIds = result.success ? result.data.map((row) => row.property_id) : [];
  if (propertyIds.length === 0) {
    return { clause: 'WHERE 1 = 0', params: [] };
  }

  const placeholders = propertyIds.map(() => '?').join(',');
  return { clause: `WHERE u.property_id IN (${placeholders})`, params: propertyIds };
};

router.get('/dashboard', async (req, res, next) => {
  try {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1;

    const propertyFilter = await buildPropertyFilter(req.user);

    const unitStatsResult = await executeQuery(
      `SELECT COUNT(*) AS total,
              SUM(CASE WHEN status = 'OCCUPIED' THEN 1 ELSE 0 END) AS occupied,
              SUM(CASE WHEN status = 'VACANT' THEN 1 ELSE 0 END) AS vacant,
              SUM(CASE WHEN status = 'MAINTENANCE' THEN 1 ELSE 0 END) AS maintenance
       FROM units u
       ${propertyFilter.clause}`,
      propertyFilter.params
    );

    const revenueResult = await executeQuery(
      `SELECT
         SUM(CASE WHEN status = 'COMPLETED' AND year = ? THEN amount ELSE 0 END) AS collectedThisYear,
         SUM(CASE WHEN status = 'COMPLETED' AND year = ? AND month = ? THEN amount ELSE 0 END) AS collectedThisMonth
       FROM payments pay
       INNER JOIN units u ON u.id = pay.unit_id
       ${propertyFilter.clause}`,
      [...propertyFilter.params, currentYear, currentYear, currentMonth]
    );

    const maintenanceResult = await executeQuery(
      `SELECT status, COUNT(*) AS count
       FROM maintenance m
       INNER JOIN units u ON u.id = m.unit_id
       ${propertyFilter.clause}
       GROUP BY status`,
      propertyFilter.params
    );

    const monthlyTrendResult = await executeQuery(
      `SELECT year, month, SUM(amount) AS revenue
       FROM payments pay
       INNER JOIN units u ON u.id = pay.unit_id
       ${propertyFilter.clause.length ? propertyFilter.clause + ' AND' : 'WHERE'}
         status = 'COMPLETED'
         AND (year = ? OR year = ?)
       GROUP BY year, month
       ORDER BY year DESC, month DESC
       LIMIT 12`,
      [...propertyFilter.params, currentYear, currentYear - 1]
    );

    const unitStats = unitStatsResult.success && unitStatsResult.data.length > 0
      ? unitStatsResult.data[0]
      : { total: 0, occupied: 0, vacant: 0, maintenance: 0 };

    const revenueStats = revenueResult.success && revenueResult.data.length > 0
      ? revenueResult.data[0]
      : { collectedThisYear: 0, collectedThisMonth: 0 };

    const maintenanceStats = maintenanceResult.success
      ? maintenanceResult.data.reduce(
          (acc, row) => ({ ...acc, [row.status]: row.count }),
          { PENDING: 0, IN_PROGRESS: 0, RESOLVED: 0, CANCELLED: 0 }
        )
      : { PENDING: 0, IN_PROGRESS: 0, RESOLVED: 0, CANCELLED: 0 };

    const totalUnits = Number(unitStats.total || 0);
    const occupiedUnits = Number(unitStats.occupied || 0);
    const vacantUnits = Number(unitStats.vacant || 0);
    const maintenanceUnits = Number(unitStats.maintenance || 0);
    const occupancyRate = totalUnits > 0 ? Math.round((occupiedUnits / totalUnits) * 10000) / 100 : 0;

    const monthlyTrend = (monthlyTrendResult.success ? monthlyTrendResult.data : [])
      .map((row) => ({
        year: row.year,
        month: row.month,
        revenue: Number(row.revenue || 0),
      }))
      .sort((a, b) => new Date(a.year, a.month - 1) - new Date(b.year, b.month - 1));

    res.json({
      overview: {
        totalUnits,
        occupiedUnits,
        vacantUnits,
        maintenanceUnits,
        occupancyRate,
      },
      revenue: {
        totalCollected: Number(revenueStats.collectedThisYear || 0),
        monthlyRevenue: Number(revenueStats.collectedThisMonth || 0),
      },
      maintenance: {
        pending: Number(maintenanceStats.PENDING || 0),
        inProgress: Number(maintenanceStats.IN_PROGRESS || 0),
        resolved: Number(maintenanceStats.RESOLVED || 0),
        cancelled: Number(maintenanceStats.CANCELLED || 0),
      },
      trends: {
        monthlyRevenue: monthlyTrend,
      },
    });
  } catch (error) {
    next(error);
  }
});

router.get('/properties/:id', async (req, res, next) => {
  try {
    const propertyId = req.params.id;

    if (req.user.role === 'CARETAKER') {
      const accessResult = await executeQuery(
        `SELECT 1 FROM property_caretakers WHERE property_id = ? AND user_id = ? LIMIT 1`,
        [propertyId, req.user.id]
      );
      if (!accessResult.success || accessResult.data.length === 0) {
        return res.status(403).json({ error: 'Access denied' });
      }
    }

    const unitStatsResult = await executeQuery(
      `SELECT COUNT(*) AS total,
              SUM(CASE WHEN status = 'OCCUPIED' THEN 1 ELSE 0 END) AS occupied,
              SUM(CASE WHEN status = 'VACANT' THEN 1 ELSE 0 END) AS vacant
       FROM units
       WHERE property_id = ?`,
      [propertyId]
    );

    const revenueResult = await executeQuery(
      `SELECT SUM(amount) AS total
       FROM payments
       WHERE unit_id IN (SELECT id FROM units WHERE property_id = ?) AND status = 'COMPLETED'`,
      [propertyId]
    );

    res.json({
      propertyId,
      units: unitStatsResult.success && unitStatsResult.data.length > 0 ? unitStatsResult.data[0] : {},
      revenue: revenueResult.success && revenueResult.data.length > 0 ? revenueResult.data[0].total : 0,
    });
  } catch (error) {
    next(error);
  }
});

export default router;




