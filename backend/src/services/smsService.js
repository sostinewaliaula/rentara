const twilio = require('twilio');
const { AT_API_KEY, AT_USERNAME, TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER } = require('../config/env');
const prisma = require('../config/database');

// Initialize Twilio client if credentials are provided and valid
let twilioClient = null;
if (TWILIO_ACCOUNT_SID && 
    TWILIO_AUTH_TOKEN && 
    TWILIO_ACCOUNT_SID.trim() !== '' && 
    TWILIO_AUTH_TOKEN.trim() !== '' &&
    TWILIO_ACCOUNT_SID.startsWith('AC')) {
  try {
    twilioClient = twilio(TWILIO_ACCOUNT_SID.trim(), TWILIO_AUTH_TOKEN.trim());
  } catch (error) {
    console.warn('Failed to initialize Twilio client:', error.message);
    twilioClient = null;
  }
}

// Initialize Africa's Talking if credentials are provided and valid
let atClient = null;
if (AT_API_KEY && 
    AT_USERNAME && 
    AT_API_KEY.trim() !== '' && 
    AT_USERNAME.trim() !== '') {
  try {
    const AfricasTalking = require('africastalking');
    atClient = AfricasTalking({
      apiKey: AT_API_KEY.trim(),
      username: AT_USERNAME.trim(),
    });
  } catch (error) {
    console.warn('Failed to initialize Africa\'s Talking client:', error.message);
    atClient = null;
  }
}

/**
 * Send SMS using Twilio or Africa's Talking
 */
const sendSMS = async (phoneNumber, message) => {
  try {
    // Remove leading + and ensure proper format
    const formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : `+${phoneNumber}`;

    // Try Twilio first if available
    if (twilioClient && TWILIO_PHONE_NUMBER) {
      const result = await twilioClient.messages.create({
        body: message,
        from: TWILIO_PHONE_NUMBER,
        to: formattedPhone,
      });
      console.log('SMS sent via Twilio:', result.sid);
      return { success: true, provider: 'twilio', sid: result.sid };
    }

    // Fallback to Africa's Talking
    if (atClient) {
      const sms = atClient.SMS();
      const result = await sms.send({
        to: formattedPhone,
        message: message,
      });
      console.log('SMS sent via Africa\'s Talking:', result);
      return { success: true, provider: 'africas_talking', result };
    }

    // If no SMS provider configured, log and return
    console.warn('No SMS provider configured. Message would be:', message);
    return { success: false, error: 'No SMS provider configured' };
  } catch (error) {
    console.error('Error sending SMS:', error);
    return { success: false, error: error.message };
  }
};

/**
 * Send notification and save to database
 */
const sendNotification = async (userId, title, message, medium = 'SMS') => {
  try {
    // Save to database
    const notification = await prisma.notification.create({
      data: {
        userId,
        title,
        message,
        medium: medium.toUpperCase(),
      },
    });

    // Send SMS if medium is SMS
    if (medium === 'SMS') {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { phone: true },
      });

      if (user) {
        await sendSMS(user.phone, `${title}\n\n${message}`);
      }
    }

    return notification;
  } catch (error) {
    console.error('Error sending notification:', error);
    throw error;
  }
};

module.exports = {
  sendSMS,
  sendNotification,
};



