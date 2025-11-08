import express from 'express';
import { executeQuery } from '../config/database.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticate);

router.get('/', async (req, res, next) => {
  try {
    const page = parseInt(req.query.page || '1', 10);
    const limit = parseInt(req.query.limit || '20', 10);
    const unreadOnly = req.query.unreadOnly === 'true';
    const offset = (page - 1) * limit;

    const conditions = ['user_id = ?'];
    const params = [req.user.id];

    if (unreadOnly) {
      conditions.push('is_read = 0');
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const listResult = await executeQuery(
      `SELECT id, title, message, medium, is_read AS isRead, created_at AS createdAt
       FROM notifications
       ${whereClause}
       ORDER BY created_at DESC
       LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    if (!listResult.success) throw listResult.error;

    const countResult = await executeQuery(
      `SELECT COUNT(*) AS total FROM notifications ${whereClause}`,
      params
    );

    const unreadResult = await executeQuery(
      `SELECT COUNT(*) AS total FROM notifications WHERE user_id = ? AND is_read = 0`,
      [req.user.id]
    );

    const total = countResult.success ? countResult.data[0].total : 0;
    const unreadCount = unreadResult.success ? unreadResult.data[0].total : 0;

    res.json({
      notifications: listResult.data,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit) || 1,
      },
      unreadCount,
    });
  } catch (error) {
    next(error);
  }
});

router.put('/:id/read', async (req, res, next) => {
  try {
    const updateResult = await executeQuery(
      `UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );

    if (!updateResult.success) throw updateResult.error;
    if (updateResult.data.affectedRows === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    next(error);
  }
});

router.put('/read-all', async (req, res, next) => {
  try {
    const updateResult = await executeQuery(
      `UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0`,
      [req.user.id]
    );

    if (!updateResult.success) throw updateResult.error;

    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    next(error);
  }
});

export default router;




