const express = require('express');
const { body, validationResult } = require('express-validator');
const prisma = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');
const { sendNotification } = require('../services/smsService');

const router = express.Router();

router.use(authenticate);

/**
 * @route   GET /api/maintenance
 * @desc    Get maintenance requests (filtered by role)
 * @access  Private
 */
router.get('/', async (req, res, next) => {
  try {
    let maintenance;

    if (req.user.role === 'ADMIN') {
      maintenance = await prisma.maintenance.findMany({
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
          createdBy: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
          assignedTo: {
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
      // Get maintenance for units in assigned properties
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

      maintenance = await prisma.maintenance.findMany({
        where: {
          unitId: {
            in: units.map(u => u.id),
          },
        },
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
          createdBy: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
          assignedTo: {
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
      // Tenant - only their requests
      const units = await prisma.unit.findMany({
        where: { tenantId: req.user.id },
        select: { id: true },
      });

      maintenance = await prisma.maintenance.findMany({
        where: {
          unitId: {
            in: units.map(u => u.id),
          },
        },
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
          assignedTo: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      });
    }

    res.json({ maintenance });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/maintenance/:id
 * @desc    Get maintenance request by ID
 * @access  Private
 */
router.get('/:id', async (req, res, next) => {
  try {
    const maintenance = await prisma.maintenance.findUnique({
      where: { id: req.params.id },
      include: {
        unit: {
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
        },
        createdBy: {
          select: {
            id: true,
            name: true,
            phone: true,
          },
        },
        assignedTo: {
          select: {
            id: true,
            name: true,
            phone: true,
          },
        },
      },
    });

    if (!maintenance) {
      return res.status(404).json({ error: 'Maintenance request not found' });
    }

    // Check access
    if (req.user.role === 'TENANT' && maintenance.createdById !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ maintenance });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/maintenance
 * @desc    Create maintenance request
 * @access  Private
 */
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

      const { unitId, description, images: imagesInput } = req.body;

      // Verify unit access
      const unit = await prisma.unit.findUnique({
        where: { id: unitId },
        include: {
          property: true,
          tenant: true,
        },
      });

      if (!unit) {
        return res.status(404).json({ error: 'Unit not found' });
      }

      // Check if tenant owns the unit or is caretaker/admin
      if (req.user.role === 'TENANT' && unit.tenantId !== req.user.id) {
        return res.status(403).json({ error: 'You are not assigned to this unit' });
      }

      const maintenance = await prisma.maintenance.create({
        data: {
          unitId,
          description,
          images: imagesInput ? (Array.isArray(imagesInput) ? imagesInput : [imagesInput]) : [],
          createdById: req.user.id,
          status: 'PENDING',
        },
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
          createdBy: {
            select: {
              id: true,
              name: true,
              phone: true,
            },
          },
        },
      });

      // Notify admin
      const admins = await prisma.user.findMany({
        where: { role: 'ADMIN' },
        select: { id: true },
      });

      for (const admin of admins) {
        await sendNotification(
          admin.id,
          'New Maintenance Request',
          `New maintenance request for ${unit.name} at ${unit.property.name}: ${description}`,
          'IN_APP'
        );
      }

      res.status(201).json({
        message: 'Maintenance request created successfully',
        maintenance,
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   PUT /api/maintenance/:id
 * @desc    Update maintenance request
 * @access  Private
 */
router.put('/:id', async (req, res, next) => {
  try {
    const maintenance = await prisma.maintenance.findUnique({
      where: { id: req.params.id },
      include: {
        unit: {
          include: {
            tenant: true,
          },
        },
        createdBy: true,
      },
    });

    if (!maintenance) {
      return res.status(404).json({ error: 'Maintenance request not found' });
    }

    // Check permissions
    if (req.user.role === 'TENANT' && maintenance.createdById !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const { status, assignedToId, notes, description } = req.body;
    const oldStatus = maintenance.status;

    const updatedMaintenance = await prisma.maintenance.update({
      where: { id: req.params.id },
      data: {
        ...(status && { status }),
        ...(assignedToId && { assignedToId }),
        ...(notes && { notes }),
        ...(description && { description }),
        ...(status === 'RESOLVED' && { resolvedAt: new Date() }),
      },
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
        createdBy: {
          select: {
            id: true,
            name: true,
            phone: true,
          },
        },
        assignedTo: {
          select: {
            id: true,
            name: true,
            phone: true,
          },
        },
      },
    });

    // Send notifications on status change
    if (status && status !== oldStatus) {
      const statusMessages = {
        IN_PROGRESS: 'Your maintenance request is now in progress',
        RESOLVED: 'Your maintenance request has been resolved',
        CANCELLED: 'Your maintenance request has been cancelled',
      };

      if (statusMessages[status] && maintenance.createdBy) {
        await sendNotification(
          maintenance.createdById,
          'Maintenance Update',
          `${statusMessages[status]} for ${maintenance.unit.name}.${notes ? ` Notes: ${notes}` : ''}`,
          'SMS'
        );
      }
    }

    res.json({
      message: 'Maintenance request updated successfully',
      maintenance: updatedMaintenance,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;



