import twilio from 'twilio';
import AfricasTalking from 'africastalking';
import { randomUUID } from 'crypto';
import {
  AT_API_KEY,
  AT_USERNAME,
  TWILIO_ACCOUNT_SID,
  TWILIO_AUTH_TOKEN,
  TWILIO_PHONE_NUMBER,
} from '../config/env.js';
import { executeQuery } from '../config/database.js';

let twilioClient = null;
if (
  TWILIO_ACCOUNT_SID &&
  TWILIO_AUTH_TOKEN &&
  TWILIO_ACCOUNT_SID.trim() !== '' &&
  TWILIO_AUTH_TOKEN.trim() !== '' &&
  TWILIO_ACCOUNT_SID.startsWith('AC')
) {
  try {
    twilioClient = twilio(TWILIO_ACCOUNT_SID.trim(), TWILIO_AUTH_TOKEN.trim());
  } catch (error) {
    console.warn('Failed to initialize Twilio client:', error.message);
    twilioClient = null;
  }
}

let atClient = null;
if (AT_API_KEY && AT_USERNAME && AT_API_KEY.trim() !== '' && AT_USERNAME.trim() !== '') {
  try {
    atClient = AfricasTalking({
      apiKey: AT_API_KEY.trim(),
      username: AT_USERNAME.trim(),
    });
  } catch (error) {
    console.warn("Failed to initialize Africa's Talking client:", error.message);
    atClient = null;
  }
}

export const sendSMS = async (phoneNumber, message) => {
  try {
    const formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : `+${phoneNumber}`;

    if (twilioClient && TWILIO_PHONE_NUMBER) {
      const result = await twilioClient.messages.create({
        body: message,
        from: TWILIO_PHONE_NUMBER,
        to: formattedPhone,
      });
      console.log('SMS sent via Twilio:', result.sid);
      return { success: true, provider: 'twilio', sid: result.sid };
    }

    if (atClient) {
      const sms = atClient.SMS();
      const result = await sms.send({
        to: formattedPhone,
        message,
      });
      console.log("SMS sent via Africa's Talking:", result);
      return { success: true, provider: 'africas_talking', result };
    }

    console.warn('No SMS provider configured. Message would be:', message);
    return { success: false, error: 'No SMS provider configured' };
  } catch (error) {
    console.error('Error sending SMS:', error);
    return { success: false, error: error.message };
  }
};

export const sendNotification = async (userId, title, message, medium = 'SMS') => {
  try {
    const notificationId = randomUUID();
    const normalizedMedium = medium.toUpperCase();

    const insertResult = await executeQuery(
      `INSERT INTO notifications (id, user_id, title, message, medium, is_read, created_at)
       VALUES (?, ?, ?, ?, ?, 0, NOW())`,
      [notificationId, userId, title, message, normalizedMedium]
    );

    if (!insertResult.success) {
      throw insertResult.error;
    }

    if (normalizedMedium === 'SMS') {
      const userResult = await executeQuery(
        `SELECT phone FROM users WHERE id = ? LIMIT 1`,
        [userId]
      );

      if (userResult.success && userResult.data.length > 0) {
        await sendSMS(userResult.data[0].phone, `${title}\n\n${message}`);
      }
    }

    return {
      id: notificationId,
      userId,
      title,
      message,
      medium: normalizedMedium,
    };
  } catch (error) {
    console.error('Error sending notification:', error);
    throw error;
  }
};



