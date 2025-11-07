const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const prisma = require('../config/database');
const { authenticate } = require('../middleware/auth');
const { JWT_SECRET, JWT_EXPIRES_IN } = require('../config/env');
const { sendSMS, sendNotification } = require('../services/smsService');

const router = express.Router();

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post(
  '/register',
  [
    body('name').trim().notEmpty().withMessage('Name is required'),
    body('phone').trim().notEmpty().matches(/^(\+254|0)[0-9]{9}$/).withMessage('Valid phone number is required'),
    body('email').optional().isEmail().withMessage('Valid email is required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('role').isIn(['ADMIN', 'CARETAKER', 'TENANT']).withMessage('Valid role is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { name, phone, email, password, role } = req.body;

      // Format phone number
      const formattedPhone = phone.startsWith('0') ? `+254${phone.slice(1)}` : phone.startsWith('+') ? phone : `+${phone}`;

      // Check if user exists
      const existingUser = await prisma.user.findFirst({
        where: {
          OR: [
            { phone: formattedPhone },
            ...(email ? [{ email }] : []),
          ],
        },
      });

      if (existingUser) {
        return res.status(400).json({ error: 'User with this phone or email already exists' });
      }

      // Hash password
      const passwordHash = await bcrypt.hash(password, 10);

      // Create user
      const user = await prisma.user.create({
        data: {
          name,
          phone: formattedPhone,
          email,
          passwordHash,
          role,
        },
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          role: true,
          createdAt: true,
        },
      });

      // Generate JWT
      const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, {
        expiresIn: JWT_EXPIRES_IN,
      });

      // Send welcome SMS
      await sendSMS(user.phone, `Welcome to Rentara! Your account has been created successfully.`);

      res.status(201).json({
        message: 'User registered successfully',
        user,
        token,
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   POST /api/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post(
  '/login',
  [
    body('phone').trim().notEmpty().withMessage('Phone number is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { phone, password } = req.body;

      // Format phone number
      const formattedPhone = phone.startsWith('0') ? `+254${phone.slice(1)}` : phone.startsWith('+') ? phone : `+${phone}`;

      // Find user
      const user = await prisma.user.findUnique({
        where: { phone: formattedPhone },
      });

      if (!user || !user.isActive) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Verify password
      const isValidPassword = await bcrypt.compare(password, user.passwordHash);
      if (!isValidPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Generate JWT
      const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, {
        expiresIn: JWT_EXPIRES_IN,
      });

      res.json({
        message: 'Login successful',
        user: {
          id: user.id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          role: user.role,
        },
        token,
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   POST /api/auth/request-password-reset
 * @desc    Request password reset OTP
 * @access  Public
 */
router.post(
  '/request-password-reset',
  [
    body('phone').trim().notEmpty().withMessage('Phone number is required'),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { phone } = req.body;
      const formattedPhone = phone.startsWith('0') ? `+254${phone.slice(1)}` : phone.startsWith('+') ? phone : `+${phone}`;

      const user = await prisma.user.findUnique({
        where: { phone: formattedPhone },
      });

      if (!user) {
        // Don't reveal if user exists for security
        return res.json({ message: 'If the phone number exists, an OTP has been sent' });
      }

      // Generate 6-digit OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      
      // In production, store OTP in Redis or database with expiry
      // For now, we'll just send it
      await sendSMS(user.phone, `Your Rentara password reset OTP is: ${otp}. Valid for 10 minutes.`);

      res.json({ message: 'OTP sent to your phone number' });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   GET /api/auth/me
 * @desc    Get current user
 * @access  Private
 */
router.get('/me', authenticate, async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        role: true,
        createdAt: true,
      },
    });

    res.json({ user });
  } catch (error) {
    next(error);
  }
});

module.exports = router;




