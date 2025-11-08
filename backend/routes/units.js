import express from 'express';
import { body, validationResult } from 'express-validator';
import { randomUUID } from 'crypto';
import { executeQuery } from '../config/database.js';
import { authenticate, authorize } from '../middleware/auth.js';
import { sendNotification } from '../services/smsService.js';

const router = express.Router();

router.use(authenticate);

router.get('/', async (req, res, next) => {
  try {
    let query = '';
    let params = [];

    if (req.user.role === 'ADMIN') {
      query = `SELECT u.id,
                      u.name,
                      u.status,
                      u.rent_amount AS rentAmount,
                      u.description,
                      u.property_id,
                      u.tenant_id,
                      u.created_at,
                      p.name AS property_name,
                      p.location AS property_location,
                      t.name AS tenant_name,
                      t.phone AS tenant_phone
               FROM units u
               INNER JOIN properties p ON p.id = u.property_id
               LEFT JOIN users t ON t.id = u.tenant_id
               ORDER BY u.created_at DESC`;
    } else if (req.user.role === 'CARETAKER') {
      query = `SELECT u.id,
                      u.name,
                      u.status,
                      u.rent_amount AS rentAmount,
                      u.description,
                      u.property_id,
                      u.tenant_id,
                      u.created_at,
                      p.name AS property_name,
                      p.location AS property_location,
                      t.name AS tenant_name,
                      t.phone AS tenant_phone
               FROM units u
               INNER JOIN properties p ON p.id = u.property_id
               INNER JOIN property_caretakers pc ON pc.property_id = p.id AND pc.user_id = ?
               LEFT JOIN users t ON t.id = u.tenant_id
               ORDER BY u.created_at DESC`;
      params = [req.user.id];
    } else {
      query = `SELECT u.id,
                      u.name,
                      u.status,
                      u.rent_amount AS rentAmount,
                      u.description,
                      u.property_id,
                      u.tenant_id,
                      u.created_at,
                      p.name AS property_name,
                      p.location AS property_location
               FROM units u
               INNER JOIN properties p ON p.id = u.property_id
               WHERE u.tenant_id = ?
               ORDER BY u.created_at DESC`;
      params = [req.user.id];
    }

    const result = await executeQuery(query, params);
    if (!result.success) throw result.error;

    const units = result.data.map((row) => ({
      id: row.id,
      name: row.name,
      status: row.status,
      rentAmount: Number(row.rentAmount ?? 0),
      description: row.description,
      property: {
        id: row.property_id,
        name: row.property_name,
        location: row.property_location,
      },
      tenant: row.tenant_id
        ? {
            id: row.tenant_id,
            name: row.tenant_name,
            phone: row.tenant_phone,
          }
        : null,
      createdAt: row.created_at,
    }));

    res.json({ units });
  } catch (error) {
    next(error);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const unitResult = await executeQuery(
      `SELECT u.id,
              u.name,
              u.status,
              u.rent_amount AS rentAmount,
              u.description,
              u.property_id,
              u.tenant_id,
              u.created_at,
              u.updated_at,
              p.name AS property_name,
              p.location AS property_location,
              p.type AS property_type,
              t.name AS tenant_name,
              t.phone AS tenant_phone,
              t.email AS tenant_email
       FROM units u
       INNER JOIN properties p ON p.id = u.property_id
       LEFT JOIN users t ON t.id = u.tenant_id
       WHERE u.id = ?
       LIMIT 1`,
      [req.params.id]
    );

    if (!unitResult.success || unitResult.data.length === 0) {
      return res.status(404).json({ error: 'Unit not found' });
    }

    const unit = unitResult.data[0];

    if (req.user.role === 'TENANT' && unit.tenant_id !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (req.user.role === 'CARETAKER') {
      const accessResult = await executeQuery(
        `SELECT 1 FROM property_caretakers WHERE property_id = ? AND user_id = ? LIMIT 1`,
        [unit.property_id, req.user.id]
      );
      if (!accessResult.success || accessResult.data.length === 0) {
        return res.status(403).json({ error: 'Access denied' });
      }
    }

    const paymentsResult = await executeQuery(
      `SELECT id, amount, status, month, year, paid_at AS paidAt
       FROM payments
       WHERE unit_id = ?
       ORDER BY year DESC, month DESC
       LIMIT 12`,
      [req.params.id]
    );

    const maintenanceResult = await executeQuery(
      `SELECT id, description, status, created_at AS createdAt
       FROM maintenance
       WHERE unit_id = ?
       ORDER BY created_at DESC
       LIMIT 10`,
      [req.params.id]
    );

    res.json({
      unit: {
        id: unit.id,
        name: unit.name,
        status: unit.status,
        rentAmount: Number(unit.rentAmount ?? 0),
        description: unit.description,
        property: {
          id: unit.property_id,
          name: unit.property_name,
          location: unit.property_location,
          type: unit.property_type,
        },
        tenant: unit.tenant_id
          ? {
              id: unit.tenant_id,
              name: unit.tenant_name,
              phone: unit.tenant_phone,
              email: unit.tenant_email,
            }
          : null,
        payments: paymentsResult.success
          ? paymentsResult.data.map((payment) => ({
              ...payment,
              amount: Number(payment.amount ?? 0),
            }))
          : [],
        maintenance: maintenanceResult.success ? maintenanceResult.data : [],
        createdAt: unit.created_at,
        updatedAt: unit.updated_at,
      },
    });
  } catch (error) {
    next(error);
  }
});

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
      const unitId = randomUUID();

      const createResult = await executeQuery(
        `INSERT INTO units (id, property_id, name, rent_amount, description, images, status, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
        [
          unitId,
          propertyId,
          name,
          parseFloat(rentAmount),
          description || null,
          JSON.stringify(Array.isArray(images) ? images : images ? [images] : []),
          status || 'VACANT',
        ]
      );

      if (!createResult.success) throw createResult.error;

      res.status(201).json({
        message: 'Unit created successfully',
        unit: {
          id: unitId,
          propertyId,
          name,
          rentAmount: parseFloat(rentAmount),
          status: status || 'VACANT',
        },
      });
    } catch (error) {
      next(error);
    }
  }
);

router.put(
  '/:id',
  authorize('ADMIN'),
  async (req, res, next) => {
    try {
      const fields = [];
      const values = [];
      const allowed = ['name', 'status', 'rentAmount', 'description', 'tenantId'];

      allowed.forEach((key) => {
        if (key in req.body) {
          if (key === 'rentAmount') {
            fields.push('rent_amount = ?');
            values.push(parseFloat(req.body[key]));
          } else if (key === 'tenantId') {
            fields.push('tenant_id = ?');
            values.push(req.body[key] || null);
          } else {
            fields.push(`${key === 'name' ? 'name' : key === 'status' ? 'status' : 'description'} = ?`);
            values.push(req.body[key]);
          }
        }
      });

      if (Array.isArray(req.body.images)) {
        fields.push('images = ?');
        values.push(JSON.stringify(req.body.images));
      }

      if (fields.length === 0) {
        return res.status(400).json({ error: 'No valid fields provided' });
      }

      values.push(req.params.id);

      const updateResult = await executeQuery(
        `UPDATE units SET ${fields.join(', ')}, updated_at = NOW() WHERE id = ?`,
        values
      );

      if (!updateResult.success) throw updateResult.error;

      res.json({ message: 'Unit updated successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.post('/:id/notify-tenant', authorize('ADMIN', 'CARETAKER'), async (req, res, next) => {
  try {
    const unitResult = await executeQuery(
      `SELECT tenant_id FROM units WHERE id = ?`,
      [req.params.id]
    );

    if (!unitResult.success || unitResult.data.length === 0 || !unitResult.data[0].tenant_id) {
      return res.status(404).json({ error: 'Tenant not found for this unit' });
    }

    const { title, message, medium } = req.body;
    await sendNotification(unitResult.data[0].tenant_id, title || 'Unit Notification', message || '', medium || 'SMS');
    res.json({ message: 'Notification sent successfully' });
  } catch (error) {
    next(error);
  }
});

export default router;



