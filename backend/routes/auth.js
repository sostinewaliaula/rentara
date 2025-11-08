import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { body, validationResult } from 'express-validator';
import { randomUUID } from 'crypto';
import { executeQuery } from '../config/database.js';
import { authenticate } from '../middleware/auth.js';
import { JWT_SECRET, JWT_EXPIRES_IN } from '../config/env.js';
import { sendSMS, sendNotification } from '../services/smsService.js';

const router = express.Router();

const formatPhoneNumber = (phone) => {
  if (!phone) return phone;
  const trimmed = phone.trim();
  if (trimmed.startsWith('+')) return trimmed;
  if (trimmed.startsWith('0')) return `+254${trimmed.slice(1)}`;
  if (!trimmed.startsWith('254')) return `+${trimmed}`;
  return `+${trimmed}`;
};

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
      const formattedPhone = formatPhoneNumber(phone);

      const existingUserResult = await executeQuery(
        `SELECT id FROM users WHERE phone = ? ${email ? 'OR email = ?' : ''} LIMIT 1`,
        email ? [formattedPhone, email] : [formattedPhone]
      );

      if (existingUserResult.success && existingUserResult.data.length > 0) {
        return res.status(400).json({ error: 'User with this phone or email already exists' });
      }

      const passwordHash = await bcrypt.hash(password, 10);
      const userId = randomUUID();

      const createResult = await executeQuery(
        `INSERT INTO users (id, name, phone, email, role, password_hash, is_active, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, 1, NOW(), NOW())`,
        [userId, name, formattedPhone, email || null, role, passwordHash]
      );

      if (!createResult.success) {
        throw createResult.error;
      }

      const token = jwt.sign({ userId, role }, JWT_SECRET, {
        expiresIn: JWT_EXPIRES_IN,
      });

      await sendSMS(formattedPhone, 'Welcome to Rentara! Your account has been created successfully.');

      res.status(201).json({
        message: 'User registered successfully',
        user: {
          id: userId,
          name,
          phone: formattedPhone,
          email,
          role,
          createdAt: new Date().toISOString(),
        },
        token,
      });
    } catch (error) {
      next(error);
    }
  }
);

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
      const formattedPhone = formatPhoneNumber(phone);

      const userResult = await executeQuery(
        `SELECT id, name, phone, email, role, password_hash, is_active
         FROM users
         WHERE phone = ?
         LIMIT 1`,
        [formattedPhone]
      );

      if (!userResult.success || userResult.data.length === 0 || !userResult.data[0].is_active) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const user = userResult.data[0];
      const isValidPassword = await bcrypt.compare(password, user.password_hash);
      if (!isValidPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

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
      const formattedPhone = formatPhoneNumber(phone);

      const userResult = await executeQuery(
        `SELECT id FROM users WHERE phone = ? LIMIT 1`,
        [formattedPhone]
      );

      if (!userResult.success || userResult.data.length === 0) {
        return res.json({ message: 'If the phone number exists, an OTP has been sent' });
      }

      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      await sendSMS(formattedPhone, `Your Rentara password reset OTP is: ${otp}. Valid for 10 minutes.`);

      res.json({ message: 'OTP sent to your phone number' });
    } catch (error) {
      next(error);
    }
  }
);

router.get('/me', authenticate, async (req, res, next) => {
  try {
    const userResult = await executeQuery(
      `SELECT id, name, phone, email, role, created_at AS createdAt
       FROM users
       WHERE id = ?
       LIMIT 1`,
      [req.user.id]
    );

    if (!userResult.success || userResult.data.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user: userResult.data[0] });
  } catch (error) {
    next(error);
  }
});

router.post('/notify', authenticate, async (req, res, next) => {
  try {
    const { userId, title, message, medium } = req.body;
    if (!userId || !title || !message) {
      return res.status(400).json({ error: 'userId, title and message are required' });
    }

    const notification = await sendNotification(userId, title, message, medium || 'SMS');
    res.json({ success: true, notification });
  } catch (error) {
    next(error);
  }
});

export default router;




