# Rentara Backend

Node.js/Express backend for the Rentara rental housing management system.

## Prerequisites

- Node.js 18+ 
- MariaDB 10.11+ or MySQL 8.0+
- Docker & Docker Compose (optional, for containerized deployment)

## Setup

### Option 1: Local Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. Set up MariaDB/MySQL database:
   ```bash
   # Using MySQL command line
   mysql -u root -p
   CREATE DATABASE rentara;
   CREATE USER 'rentara'@'localhost' IDENTIFIED BY 'rentara123';
   GRANT ALL PRIVILEGES ON rentara.* TO 'rentara'@'localhost';
   FLUSH PRIVILEGES;
   EXIT;
   ```

4. Run Prisma migrations:
   ```bash
   npx prisma migrate dev
   ```

5. Generate Prisma Client:
   ```bash
   npx prisma generate
   ```

6. Seed database (optional):
   ```bash
   npm run prisma:seed
   ```

7. Start the server:
   ```bash
   npm run dev
   ```

The server will run on `http://localhost:3000`

### Option 2: Docker Deployment

1. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. Start services:
   ```bash
   docker-compose up -d
   ```

3. Run migrations:
   ```bash
   docker-compose exec backend npx prisma migrate deploy
   ```

4. Seed database (optional):
   ```bash
   docker-compose exec backend npm run prisma:seed
   ```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user
- `POST /api/auth/request-password-reset` - Request password reset OTP

### Properties
- `GET /api/properties` - Get all properties
- `GET /api/properties/:id` - Get property by ID
- `POST /api/properties` - Create property (Admin only)
- `PUT /api/properties/:id` - Update property (Admin only)
- `POST /api/properties/:id/caretakers` - Assign caretaker (Admin only)

### Units
- `GET /api/units` - Get all units
- `GET /api/units/:id` - Get unit by ID
- `POST /api/units` - Create unit (Admin only)
- `PUT /api/units/:id` - Update unit (Admin only)
- `POST /api/units/:id/assign-tenant` - Assign tenant (Admin only)
- `POST /api/units/:id/vacate` - Vacate unit (Admin only)

### Payments
- `GET /api/payments` - Get all payments
- `GET /api/payments/:id` - Get payment by ID
- `POST /api/payments/initiate` - Initiate M-Pesa payment (Tenant only)
- `POST /api/payments/mpesa-callback` - M-Pesa webhook callback
- `GET /api/payments/arrears` - Get arrears report (Admin/Caretaker)

### Maintenance
- `GET /api/maintenance` - Get maintenance requests
- `GET /api/maintenance/:id` - Get maintenance by ID
- `POST /api/maintenance` - Create maintenance request
- `PUT /api/maintenance/:id` - Update maintenance request

### Notifications
- `GET /api/notifications` - Get user notifications
- `PUT /api/notifications/:id/read` - Mark notification as read
- `PUT /api/notifications/read-all` - Mark all as read

### USSD
- `POST /api/ussd` - Handle USSD requests (Africa's Talking webhook)

### Analytics
- `GET /api/analytics/dashboard` - Get dashboard analytics (Admin/Caretaker)
- `GET /api/analytics/properties/:id` - Get property analytics

## Environment Variables

See `.env.example` for all required environment variables.

## Database Schema

The database schema is defined in `prisma/schema.prisma`. Key models:

- **User** - Users (Admin, Caretaker, Tenant)
- **Property** - Housing properties/estates
- **Unit** - Individual housing units
- **Payment** - Rent payments
- **Maintenance** - Maintenance requests
- **Notification** - User notifications
- **USSDSession** - USSD session tracking

## Testing

Sample credentials (from seed data):
- Admin: `+254712345678` / `admin123`
- Caretaker: `+254723456789` / `caretaker123`
- Tenant: `+254734567890` / `tenant123`

## Production Deployment

1. Set `NODE_ENV=production` in `.env`
2. Use strong `JWT_SECRET`
3. Configure production database
4. Set up M-Pesa production credentials
5. Configure SMS provider (Twilio or Africa's Talking)
6. Set up reverse proxy (nginx) for HTTPS
7. Use process manager (PM2) for Node.js

## License

ISC



