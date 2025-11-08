import dotenv from 'dotenv';

dotenv.config();

export const PORT = process.env.PORT || 3000;
export const NODE_ENV = process.env.NODE_ENV || 'development';
export const DATABASE_URL = process.env.DATABASE_URL;
export const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
export const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

export const MPESA_CONSUMER_KEY = process.env.MPESA_CONSUMER_KEY;
export const MPESA_CONSUMER_SECRET = process.env.MPESA_CONSUMER_SECRET;
export const MPESA_SHORTCODE = process.env.MPESA_SHORTCODE;
export const MPESA_PASSKEY = process.env.MPESA_PASSKEY;
export const MPESA_ENVIRONMENT = process.env.MPESA_ENVIRONMENT || 'sandbox';

export const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID;
export const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN;
export const TWILIO_PHONE_NUMBER = process.env.TWILIO_PHONE_NUMBER;

export const AT_API_KEY = process.env.AT_API_KEY;
export const AT_USERNAME = process.env.AT_USERNAME;
export const AT_SMS_SHORTCODE = process.env.AT_SMS_SHORTCODE;
export const AT_USSD_SHORTCODE = process.env.AT_USSD_SHORTCODE || '*384*123#';

export const UPLOAD_DIR = process.env.UPLOAD_DIR || './uploads';
export const MAX_FILE_SIZE = parseInt(process.env.MAX_FILE_SIZE || '5242880', 10);




