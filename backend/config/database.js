import mysql from 'mysql2/promise';
import { DATABASE_URL } from './env.js';

const DEFAULT_POOL_SIZE = parseInt(process.env.DB_POOL_SIZE || '10', 10);

if (!DATABASE_URL) {
  console.warn('⚠️  DATABASE_URL is not set. Database queries will fail until it is provided.');
}

export const pool = DATABASE_URL
  ? mysql.createPool({
      uri: DATABASE_URL,
      waitForConnections: true,
      connectionLimit: DEFAULT_POOL_SIZE,
      queueLimit: 0,
    })
  : null;

export const executeQuery = async (query, params = []) => {
  if (!pool) {
    return { success: false, error: new Error('Database pool not initialized. Check DATABASE_URL.') };
  }

  let connection;
  try {
    connection = await pool.getConnection();
    const [rows] = await connection.query(query, params);
    return { success: true, data: rows };
  } catch (error) {
    console.error('Database query error:', error.message);
    return { success: false, error };
  } finally {
    if (connection) connection.release();
  }
};

export const testConnection = async () => {
  if (!pool) return false;
  try {
    const connection = await pool.getConnection();
    connection.release();
    return true;
  } catch (error) {
    console.error('Failed to establish database connection:', error.message);
    return false;
  }
};

export default {
  pool,
  executeQuery,
  testConnection,
};




