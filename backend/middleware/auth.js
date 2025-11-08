import jwt from 'jsonwebtoken';
import { JWT_SECRET } from '../config/env.js';
import { executeQuery } from '../config/database.js';

export const authenticate = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ error: 'Access denied. No token provided.' });
    }

    const decoded = jwt.verify(token, JWT_SECRET);
    const result = await executeQuery(
      `SELECT id, name, phone, email, role, is_active AS isActive
       FROM users
       WHERE id = ?
       LIMIT 1`,
      [decoded.userId]
    );

    if (!result.success || result.data.length === 0 || !result.data[0].isActive) {
      return res.status(401).json({ error: 'Invalid token or user inactive.' });
    }

    req.user = result.data[0];
    next();
  } catch (error) {
    console.error('Auth error:', error.message);
    res.status(401).json({ error: 'Invalid token.' });
  }
};

export const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required.' });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Access denied. Insufficient permissions.' });
    }

    next();
  };
};




