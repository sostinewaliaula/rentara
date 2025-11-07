const express = require('express');
const { body, validationResult } = require('express-validator');
const prisma = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/properties
 * @desc    Get all properties (Admin sees all, Caretaker sees assigned)
 * @access  Private
 */
router.get('/', async (req, res, next) => {
  try {
    let properties;

    if (req.user.role === 'ADMIN') {
      properties = await prisma.property.findMany({
        include: {
          units: {
            select: {
              id: true,
              name: true,
              status: true,
              rentAmount: true,
            },
          },
          caretakers: {
            include: {
              user: {
                select: {
                  id: true,
                  name: true,
                  phone: true,
                },
              },
            },
          },
          _count: {
            select: {
              units: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      });
    } else if (req.user.role === 'CARETAKER') {
      properties = await prisma.property.findMany({
        where: {
          caretakers: {
            some: {
              userId: req.user.id,
            },
          },
        },
        include: {
          units: {
            select: {
              id: true,
              name: true,
              status: true,
              rentAmount: true,
            },
          },
          _count: {
            select: {
              units: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      });
    } else {
      // Tenant - get properties where they have units
      const units = await prisma.unit.findMany({
        where: { tenantId: req.user.id },
        include: {
          property: true,
        },
      });

      properties = units.map(unit => ({
        ...unit.property,
        units: [unit],
      }));
    }

    res.json({ properties });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/properties/:id
 * @desc    Get property by ID
 * @access  Private
 */
router.get('/:id', async (req, res, next) => {
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
          },
        },
        caretakers: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                phone: true,
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
      const hasAccess = property.caretakers.some(c => c.userId === req.user.id);
      if (!hasAccess) {
        return res.status(403).json({ error: 'Access denied' });
      }
    }

    res.json({ property });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/properties
 * @desc    Create new property
 * @access  Private (Admin only)
 */
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

      const property = await prisma.property.create({
        data: {
          name,
          location,
          type,
          description,
        },
      });

      res.status(201).json({
        message: 'Property created successfully',
        property,
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   PUT /api/properties/:id
 * @desc    Update property
 * @access  Private (Admin only)
 */
router.put(
  '/:id',
  authorize('ADMIN'),
  [
    body('name').optional().trim().notEmpty(),
    body('location').optional().trim().notEmpty(),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const property = await prisma.property.update({
        where: { id: req.params.id },
        data: req.body,
      });

      res.json({
        message: 'Property updated successfully',
        property,
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   POST /api/properties/:id/caretakers
 * @desc    Assign caretaker to property
 * @access  Private (Admin only)
 */
router.post(
  '/:id/caretakers',
  authorize('ADMIN'),
  [
    body('userId').notEmpty().withMessage('User ID is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { userId } = req.body;

      // Verify user is a caretaker
      const user = await prisma.user.findUnique({
        where: { id: userId },
      });

      if (!user || user.role !== 'CARETAKER') {
        return res.status(400).json({ error: 'User must be a caretaker' });
      }

      const assignment = await prisma.propertyCaretaker.create({
        data: {
          propertyId: req.params.id,
          userId,
        },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
        },
      });

      res.status(201).json({
        message: 'Caretaker assigned successfully',
        assignment,
      });
    } catch (error) {
      next(error);
    }
  }
);

module.exports = router;




