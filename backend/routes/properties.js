import express from 'express';
import { body, validationResult } from 'express-validator';
import { randomUUID } from 'crypto';
import { executeQuery } from '../config/database.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticate);

const mapPropertiesWithUnits = (rows) => {
  const propertiesMap = new Map();

  rows.forEach((row) => {
    if (!propertiesMap.has(row.property_id)) {
      propertiesMap.set(row.property_id, {
        id: row.property_id,
        name: row.property_name,
        location: row.property_location,
        type: row.property_type,
        description: row.property_description,
        createdAt: row.property_created_at,
        updatedAt: row.property_updated_at,
        units: [],
      });
    }

    if (row.unit_id) {
      propertiesMap.get(row.property_id).units.push({
        id: row.unit_id,
        name: row.unit_name,
        status: row.unit_status,
        rentAmount: Number(row.unit_rent_amount ?? 0),
        tenantId: row.unit_tenant_id,
      });
    }
  });

  return Array.from(propertiesMap.values());
};

router.get('/', async (req, res, next) => {
  try {
    let query = '';
    let params = [];

    if (req.user.role === 'ADMIN') {
      query = `SELECT p.id AS property_id,
                      p.name AS property_name,
                      p.location AS property_location,
                      p.type AS property_type,
                      p.description AS property_description,
                      p.created_at AS property_created_at,
                      p.updated_at AS property_updated_at,
                      u.id AS unit_id,
                      u.name AS unit_name,
                      u.status AS unit_status,
                      u.rent_amount AS unit_rent_amount,
                      u.tenant_id AS unit_tenant_id
               FROM properties p
               LEFT JOIN units u ON u.property_id = p.id
               ORDER BY p.created_at DESC, u.name ASC`;
    } else if (req.user.role === 'CARETAKER') {
      query = `SELECT p.id AS property_id,
                      p.name AS property_name,
                      p.location AS property_location,
                      p.type AS property_type,
                      p.description AS property_description,
                      p.created_at AS property_created_at,
                      p.updated_at AS property_updated_at,
                      u.id AS unit_id,
                      u.name AS unit_name,
                      u.status AS unit_status,
                      u.rent_amount AS unit_rent_amount,
                      u.tenant_id AS unit_tenant_id
               FROM properties p
               INNER JOIN property_caretakers pc ON pc.property_id = p.id AND pc.user_id = ?
               LEFT JOIN units u ON u.property_id = p.id
               ORDER BY p.created_at DESC, u.name ASC`;
      params = [req.user.id];
    } else {
      query = `SELECT p.id AS property_id,
                      p.name AS property_name,
                      p.location AS property_location,
                      p.type AS property_type,
                      p.description AS property_description,
                      p.created_at AS property_created_at,
                      p.updated_at AS property_updated_at,
                      u.id AS unit_id,
                      u.name AS unit_name,
                      u.status AS unit_status,
                      u.rent_amount AS unit_rent_amount,
                      u.tenant_id AS unit_tenant_id
               FROM units u
               INNER JOIN properties p ON p.id = u.property_id
               WHERE u.tenant_id = ?
               ORDER BY p.created_at DESC, u.name ASC`;
      params = [req.user.id];
    }

    const result = await executeQuery(query, params);
    if (!result.success) throw result.error;

    const properties = mapPropertiesWithUnits(result.data);
    res.json({ properties });
  } catch (error) {
    next(error);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const propertyResult = await executeQuery(
      `SELECT p.id AS property_id,
              p.name AS property_name,
              p.location AS property_location,
              p.type AS property_type,
              p.description AS property_description,
              p.created_at AS property_created_at,
              p.updated_at AS property_updated_at,
              u.id AS unit_id,
              u.name AS unit_name,
              u.status AS unit_status,
              u.rent_amount AS unit_rent_amount,
              u.tenant_id AS unit_tenant_id
       FROM properties p
       LEFT JOIN units u ON u.property_id = p.id
       WHERE p.id = ?`,
      [req.params.id]
    );

    if (!propertyResult.success || propertyResult.data.length === 0) {
      return res.status(404).json({ error: 'Property not found' });
    }

    if (req.user.role === 'CARETAKER') {
      const accessResult = await executeQuery(
        `SELECT 1 FROM property_caretakers WHERE property_id = ? AND user_id = ? LIMIT 1`,
        [req.params.id, req.user.id]
      );
      if (!accessResult.success || accessResult.data.length === 0) {
        return res.status(403).json({ error: 'Access denied' });
      }
    }

    const [property] = mapPropertiesWithUnits(propertyResult.data);
    res.json({ property });
  } catch (error) {
    next(error);
  }
});

router.post(
  '/',
  authorize('ADMIN'),
  [
    body('name').trim().notEmpty().withMessage('Property name is required'),
    body('location').trim().notEmpty().withMessage('Location is required'),
    body('type').trim().notEmpty().withMessage('Property type is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { name, location, type, description } = req.body;
      const propertyId = randomUUID();

      const createResult = await executeQuery(
        `INSERT INTO properties (id, name, location, type, description, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
        [propertyId, name, location, type, description || null]
      );

      if (!createResult.success) throw createResult.error;

      res.status(201).json({
        message: 'Property created successfully',
        property: {
          id: propertyId,
          name,
          location,
          type,
          description: description || null,
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
  [
    body('name').optional().trim().notEmpty(),
    body('location').optional().trim().notEmpty(),
    body('type').optional().trim().notEmpty(),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const fields = [];
      const values = [];
      const allowed = ['name', 'location', 'type', 'description'];

      allowed.forEach((key) => {
        if (key in req.body) {
          fields.push(`${key} = ?`);
          values.push(req.body[key]);
        }
      });

      if (fields.length === 0) {
        return res.status(400).json({ error: 'No valid fields provided' });
      }

      values.push(req.params.id);

      const updateResult = await executeQuery(
        `UPDATE properties SET ${fields.join(', ')}, updated_at = NOW() WHERE id = ?`,
        values
      );

      if (!updateResult.success) throw updateResult.error;

      res.json({ message: 'Property updated successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.delete('/:id', authorize('ADMIN'), async (req, res, next) => {
  try {
    const deleteResult = await executeQuery(`DELETE FROM properties WHERE id = ?`, [req.params.id]);
    if (!deleteResult.success) throw deleteResult.error;

    res.json({ message: 'Property deleted successfully' });
  } catch (error) {
    next(error);
  }
});

export default router;




