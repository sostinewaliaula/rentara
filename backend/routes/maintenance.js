import express from 'express';
import { body, validationResult } from 'express-validator';
import { randomUUID } from 'crypto';
import { executeQuery } from '../config/database.js';
import { authenticate, authorize } from '../middleware/auth.js';
import { sendNotification } from '../services/smsService.js';

const router = express.Router();

router.use(authenticate);

const mapMaintenanceRow = (row) => ({
  id: row.id,
  unitId: row.unit_id,
  description: row.description,
  status: row.status,
  createdById: row.created_by_id,
  assignedToId: row.assigned_to_id,
  images: row.images ? JSON.parse(row.images) : [],
  createdAt: row.created_at,
  updatedAt: row.updated_at,
  unit: row.unit_id
    ? {
        id: row.unit_id,
        name: row.unit_name,
        property: {
          id: row.property_id,
          name: row.property_name,
        },
      }
    : null,
  createdBy: row.created_by_id
    ? {
        id: row.created_by_id,
        name: row.requester_name,
        phone: row.requester_phone,
      }
    : null,
  assignedTo: row.assigned_to_id
    ? {
        id: row.assigned_to_id,
        name: row.assigned_name,
        phone: row.assigned_phone,
      }
    : null,
});

router.get('/', async (req, res, next) => {
  try {
    let query = '';
    let params = [];

    if (req.user.role === 'ADMIN') {
      query = `SELECT m.*, u.name AS unit_name, u.property_id, p.name AS property_name,
                      c.name AS requester_name, c.phone AS requester_phone,
                      a.name AS assigned_name, a.phone AS assigned_phone
               FROM maintenance m
               INNER JOIN units u ON u.id = m.unit_id
               INNER JOIN properties p ON p.id = u.property_id
               LEFT JOIN users c ON c.id = m.created_by_id
               LEFT JOIN users a ON a.id = m.assigned_to_id
               ORDER BY m.created_at DESC`;
    } else if (req.user.role === 'CARETAKER') {
      query = `SELECT m.*, u.name AS unit_name, u.property_id, p.name AS property_name,
                      c.name AS requester_name, c.phone AS requester_phone,
                      a.name AS assigned_name, a.phone AS assigned_phone
               FROM maintenance m
               INNER JOIN units u ON u.id = m.unit_id
               INNER JOIN properties p ON p.id = u.property_id
               INNER JOIN property_caretakers pc ON pc.property_id = p.id AND pc.user_id = ?
               LEFT JOIN users c ON c.id = m.created_by_id
               LEFT JOIN users a ON a.id = m.assigned_to_id
               ORDER BY m.created_at DESC`;
      params = [req.user.id];
    } else {
      query = `SELECT m.*, u.name AS unit_name, u.property_id, p.name AS property_name,
                      c.name AS requester_name, c.phone AS requester_phone,
                      a.name AS assigned_name, a.phone AS assigned_phone
               FROM maintenance m
               INNER JOIN units u ON u.id = m.unit_id
               INNER JOIN properties p ON p.id = u.property_id
               WHERE m.created_by_id = ?
               ORDER BY m.created_at DESC`;
      params = [req.user.id];
    }

    const result = await executeQuery(query, params);
    if (!result.success) throw result.error;

    const maintenance = result.data.map(mapMaintenanceRow);
    res.json({ maintenance });
  } catch (error) {
    next(error);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const result = await executeQuery(
      `SELECT m.*, u.name AS unit_name, u.property_id, p.name AS property_name,
              c.name AS requester_name, c.phone AS requester_phone,
              a.name AS assigned_name, a.phone AS assigned_phone
       FROM maintenance m
       INNER JOIN units u ON u.id = m.unit_id
       INNER JOIN properties p ON p.id = u.property_id
       LEFT JOIN users c ON c.id = m.created_by_id
       LEFT JOIN users a ON a.id = m.assigned_to_id
       WHERE m.id = ?
       LIMIT 1`,
      [req.params.id]
    );

    if (!result.success || result.data.length === 0) {
      return res.status(404).json({ error: 'Maintenance request not found' });
    }

    const maintenance = mapMaintenanceRow(result.data[0]);

    if (req.user.role === 'TENANT' && maintenance.createdById !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (req.user.role === 'CARETAKER') {
      const accessResult = await executeQuery(
        `SELECT 1 FROM property_caretakers WHERE property_id = ? AND user_id = ? LIMIT 1`,
        [maintenance.unit?.property?.id, req.user.id]
      );
      if (!accessResult.success || accessResult.data.length === 0) {
        return res.status(403).json({ error: 'Access denied' });
      }
    }

    res.json({ maintenance });
  } catch (error) {
    next(error);
  }
});

router.post(
  '/',
  [
    body('unitId').notEmpty().withMessage('Unit ID is required'),
    body('description').trim().notEmpty().withMessage('Description is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { unitId, description, images } = req.body;
      const maintenanceId = randomUUID();

      const createResult = await executeQuery(
        `INSERT INTO maintenance (id, unit_id, description, status, created_by_id, images, created_at, updated_at)
         VALUES (?, ?, ?, 'PENDING', ?, ?, NOW(), NOW())`,
        [
          maintenanceId,
          unitId,
          description,
          req.user.id,
          images ? JSON.stringify(Array.isArray(images) ? images : [images]) : '[]',
        ]
      );

      if (!createResult.success) throw createResult.error;

      res.status(201).json({
        message: 'Maintenance request created successfully',
        maintenanceId,
      });
    } catch (error) {
      next(error);
    }
  }
);

router.put(
  '/:id/status',
  authorize('ADMIN', 'CARETAKER'),
  [body('status').isIn(['PENDING', 'IN_PROGRESS', 'RESOLVED', 'CANCELLED']).withMessage('Invalid status')],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const updateResult = await executeQuery(
        `UPDATE maintenance SET status = ?, updated_at = NOW() WHERE id = ?`,
        [req.body.status, req.params.id]
      );

      if (!updateResult.success) throw updateResult.error;

      res.json({ message: 'Maintenance status updated successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.put(
  '/:id/assign',
  authorize('ADMIN', 'CARETAKER'),
  [body('assignedToId').notEmpty().withMessage('Assigned user ID is required')],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { assignedToId } = req.body;
      const updateResult = await executeQuery(
        `UPDATE maintenance SET assigned_to_id = ?, updated_at = NOW() WHERE id = ?`,
        [assignedToId, req.params.id]
      );

      if (!updateResult.success) throw updateResult.error;

      await sendNotification(
        assignedToId,
        'Maintenance Assignment',
        'A new maintenance task has been assigned to you.',
        'SMS'
      );

      res.json({ message: 'Maintenance assignment updated successfully' });
    } catch (error) {
      next(error);
    }
  }
);

export default router;



