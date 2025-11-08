import express from 'express';
import { body, validationResult } from 'express-validator';
import { randomUUID } from 'crypto';
import { executeQuery } from '../config/database.js';
import { authenticate, authorize } from '../middleware/auth.js';
import { initiateSTKPush } from '../services/mpesaService.js';
import { sendNotification } from '../services/smsService.js';

const router = express.Router();

router.use(authenticate);

const mapPaymentRow = (row) => ({
  id: row.id,
  tenantId: row.tenant_id,
  unitId: row.unit_id,
  amount: Number(row.amount ?? 0),
  month: row.month,
  year: row.year,
  status: row.status,
  transactionId: row.transaction_id,
  paidAt: row.paid_at,
  tenant: row.tenant_id
    ? {
        id: row.tenant_id,
        name: row.tenant_name,
        phone: row.tenant_phone,
      }
    : null,
  unit: {
    id: row.unit_id,
    name: row.unit_name,
    property: {
      id: row.property_id,
      name: row.property_name,
    },
  },
});

router.get('/', async (req, res, next) => {
  try {
    let query = '';
    let params = [];

    if (req.user.role === 'ADMIN') {
      query = `SELECT pay.*, u.name AS unit_name, u.property_id, p.name AS property_name,
                      t.name AS tenant_name, t.phone AS tenant_phone
               FROM payments pay
               INNER JOIN units u ON u.id = pay.unit_id
               INNER JOIN properties p ON p.id = u.property_id
               LEFT JOIN users t ON t.id = pay.tenant_id
               ORDER BY pay.year DESC, pay.month DESC`;
    } else if (req.user.role === 'CARETAKER') {
      query = `SELECT pay.*, u.name AS unit_name, u.property_id, p.name AS property_name,
                      t.name AS tenant_name, t.phone AS tenant_phone
               FROM payments pay
               INNER JOIN units u ON u.id = pay.unit_id
               INNER JOIN properties p ON p.id = u.property_id
               INNER JOIN property_caretakers pc ON pc.property_id = p.id AND pc.user_id = ?
               LEFT JOIN users t ON t.id = pay.tenant_id
               ORDER BY pay.year DESC, pay.month DESC`;
      params = [req.user.id];
    } else {
      query = `SELECT pay.*, u.name AS unit_name, u.property_id, p.name AS property_name
               FROM payments pay
               INNER JOIN units u ON u.id = pay.unit_id
               INNER JOIN properties p ON p.id = u.property_id
               WHERE pay.tenant_id = ?
               ORDER BY pay.year DESC, pay.month DESC`;
      params = [req.user.id];
    }

    const result = await executeQuery(query, params);
    if (!result.success) throw result.error;

    const payments = result.data.map(mapPaymentRow);
    res.json({ payments });
  } catch (error) {
    next(error);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const result = await executeQuery(
      `SELECT pay.*, u.name AS unit_name, u.property_id, p.name AS property_name,
              t.name AS tenant_name, t.phone AS tenant_phone
       FROM payments pay
       INNER JOIN units u ON u.id = pay.unit_id
       INNER JOIN properties p ON p.id = u.property_id
       LEFT JOIN users t ON t.id = pay.tenant_id
       WHERE pay.id = ?
       LIMIT 1`,
      [req.params.id]
    );

    if (!result.success || result.data.length === 0) {
      return res.status(404).json({ error: 'Payment not found' });
    }

    const payment = mapPaymentRow(result.data[0]);

    if (req.user.role === 'TENANT' && payment.tenantId !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ payment });
  } catch (error) {
    next(error);
  }
});

router.post(
  '/record',
  authorize('ADMIN', 'CARETAKER'),
  [
    body('tenantId').notEmpty().withMessage('Tenant ID is required'),
    body('unitId').notEmpty().withMessage('Unit ID is required'),
    body('amount').isFloat({ min: 0 }).withMessage('Valid amount is required'),
    body('month').isInt({ min: 1, max: 12 }).withMessage('Valid month is required'),
    body('year').isInt({ min: 2020 }).withMessage('Valid year is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { tenantId, unitId, amount, month, year, status } = req.body;
      const paymentId = randomUUID();

      const createResult = await executeQuery(
        `INSERT INTO payments (id, tenant_id, unit_id, amount, month, year, status, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
        [paymentId, tenantId, unitId, parseFloat(amount), month, year, status || 'COMPLETED']
      );

      if (!createResult.success) throw createResult.error;

      await sendNotification(
        tenantId,
        'Payment Recorded',
        `Your payment for ${month}/${year} has been recorded.`,
        'SMS'
      );

      res.status(201).json({
        message: 'Payment recorded successfully',
        paymentId,
      });
    } catch (error) {
      next(error);
    }
  }
);

router.post(
  '/initiate',
  authorize('TENANT'),
  [
    body('unitId').notEmpty().withMessage('Unit ID is required'),
    body('amount').isFloat({ min: 1 }).withMessage('Valid amount is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { unitId, amount } = req.body;
      const unitResult = await executeQuery(
        `SELECT u.id, u.name, p.name AS property_name
         FROM units u
         INNER JOIN properties p ON p.id = u.property_id
         WHERE u.id = ? AND u.tenant_id = ?
         LIMIT 1`,
        [unitId, req.user.id]
      );

      if (!unitResult.success || unitResult.data.length === 0) {
        return res.status(403).json({ error: 'You are not assigned to this unit' });
      }

      const accountReference = `${unitResult.data[0].property_name}-${unitResult.data[0].name}`;
      const transactionDesc = `Rent payment for ${unitResult.data[0].name}`;

      const mpesaResponse = await initiateSTKPush(req.user.phone, amount, accountReference, transactionDesc);

      res.json({
        success: true,
        message: 'M-Pesa STK push initiated',
        data: mpesaResponse,
      });
    } catch (error) {
      next(error);
    }
  }
);

router.put('/:id/status', authorize('ADMIN', 'CARETAKER'), async (req, res, next) => {
  try {
    const { status } = req.body;
    if (!status) {
      return res.status(400).json({ error: 'Status is required' });
    }

    const updateResult = await executeQuery(
      `UPDATE payments SET status = ?, updated_at = NOW() WHERE id = ?`,
      [status, req.params.id]
    );

    if (!updateResult.success) throw updateResult.error;

    res.json({ message: 'Payment status updated successfully' });
  } catch (error) {
    next(error);
  }
});

export default router;




