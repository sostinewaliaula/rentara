# Rentara Setup Guide

Complete setup instructions for the Rentara rental housing management system.

## Prerequisites

### Backend
- Node.js 18 or higher
- MariaDB 10.11+ or MySQL 8.0+
- npm or yarn

### Mobile
- Flutter SDK 3.0 or higher
- Android Studio / Xcode (for mobile development)
- Dart SDK (included with Flutter)

### Optional
- Docker & Docker Compose (for containerized deployment)
- M-Pesa Daraja API credentials
- Twilio or Africa's Talking account

## Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

**Linux/Mac:**
```bash
cp .env.example .env
```

**Windows (PowerShell):**
```powershell
Copy-Item .env.example .env
```

Edit `.env` and configure:
- `DATABASE_URL` - MariaDB/MySQL connection string
- `JWT_SECRET` - Strong secret key for JWT tokens
- `MPESA_*` - M-Pesa Daraja API credentials (optional for testing)
- `TWILIO_*` or `AT_*` - SMS provider credentials (optional for testing)

### 3. Database Setup

**Option A: Using Docker**
```bash
docker-compose up -d mariadb
```

**Option B: Local MariaDB/MySQL**
```bash
# Using MySQL command line
mysql -u root -p
CREATE DATABASE rentara;
CREATE USER 'rentara'@'localhost' IDENTIFIED BY 'rentara123';
GRANT ALL PRIVILEGES ON rentara.* TO 'rentara'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 4. Run Migrations

```bash
npx prisma migrate dev
npx prisma generate
```

### 5. Seed Database (Optional)

```bash
npm run prisma:seed
```

This creates sample users:
- Admin: `+254712345678` / `admin123`
- Caretaker: `+254723456789` / `caretaker123`
- Tenant: `+254734567890` / `tenant123`

### 6. Start Server

**Development:**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

Server runs on `http://localhost:3000`

## Mobile App Setup

### 1. Install Dependencies

```bash
cd mobile
flutter pub get
```

### 2. Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure API URL

Edit `lib/core/config/app_config.dart`:

```dart
// For Android Emulator
static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

// For iOS Simulator
static const String apiBaseUrl = 'http://localhost:3000/api';

// For Physical Device (use your computer's IP)
static const String apiBaseUrl = 'http://192.168.1.100:3000/api';
```

### 4. Run the App

```bash
flutter run
```

## Docker Deployment

### Full Stack Deployment

```bash
cd backend
docker-compose up -d
```

This starts:
- MariaDB database
- Backend API server

### Run Migrations in Docker

```bash
docker-compose exec backend npx prisma migrate deploy
docker-compose exec backend npm run prisma:seed
```

## Testing the System

### 1. Test Backend API

```bash
# Health check
curl http://localhost:3000/health

# Login (using seeded credentials)
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+254712345678","password":"admin123"}'
```

### 2. Test Mobile App

1. Launch the app
2. Use seeded credentials to login
3. Navigate through different screens based on role

### 3. Test USSD (Requires Africa's Talking Setup)

1. Configure Africa's Talking credentials in `.env`
2. Set up USSD callback URL: `http://your-server.com/api/ussd`
3. Dial the USSD code (e.g., `*384*123#`)
4. Follow menu prompts

## M-Pesa Integration Setup

1. Register for M-Pesa Daraja API at https://developer.safaricom.co.ke/
2. Get your credentials:
   - Consumer Key
   - Consumer Secret
   - Shortcode
   - Passkey
3. Update `.env` with credentials
4. Set `MPESA_ENVIRONMENT=production` for live environment

## SMS Integration Setup

### Option 1: Twilio

1. Sign up at https://www.twilio.com/
2. Get Account SID and Auth Token
3. Purchase a phone number
4. Update `.env`:
   ```
   TWILIO_ACCOUNT_SID=your_sid
   TWILIO_AUTH_TOKEN=your_token
   TWILIO_PHONE_NUMBER=+1234567890
   ```

### Option 2: Africa's Talking

1. Sign up at https://africastalking.com/
2. Get API Key and Username
3. Update `.env`:
   ```
   AT_API_KEY=your_key
   AT_USERNAME=your_username
   AT_SMS_SHORTCODE=your_shortcode
   ```

## Troubleshooting

### Backend Issues

**Database Connection Error:**
- Verify MariaDB/MySQL is running
- Check `DATABASE_URL` in `.env`
- Ensure database exists
- Verify user has proper permissions

**Prisma Errors:**
```bash
npx prisma generate
npx prisma migrate reset  # WARNING: Deletes all data
```

**Port Already in Use:**
- Change `PORT` in `.env`
- Or kill process using port 3000

### Mobile Issues

**API Connection Error:**
- Verify backend is running
- Check API URL in `app_config.dart`
- For physical device, ensure phone and computer are on same network
- Check firewall settings

**Build Errors:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Riverpod Generation Errors:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Production Deployment

### Backend

1. Set `NODE_ENV=production`
2. Use strong `JWT_SECRET`
3. Configure production database
4. Set up HTTPS (nginx reverse proxy)
5. Use process manager (PM2)
6. Configure M-Pesa production credentials
7. Set up SMS provider

### Mobile

1. Update API URL to production server
2. Build release APK/IPA:
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

## Next Steps

1. Customize branding and colors
2. Add more features as needed
3. Set up monitoring and logging
4. Configure backup strategy
5. Set up CI/CD pipeline

## Support

For issues, check:
- Backend logs: `npm run dev` output
- Mobile logs: `flutter run` output
- Database: `npx prisma studio`


