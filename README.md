# Rentara - Rental Housing Management System

A comprehensive full-stack application for managing rental housing, including affordable housing units under Kenya's Affordable Housing Programme (AHP). Built with Flutter (mobile) and Node.js/Express (backend).

## Features

### 🔐 Authentication & Authorization
- JWT-based authentication
- Role-based access control (Admin, Caretaker, Tenant)
- Password reset via SMS OTP

### 🏠 Property & Unit Management
- Register properties and housing estates
- Manage housing units with details (rent, status, images)
- Assign tenants and caretakers
- Track occupancy and vacancies

### 💰 Payment Management
- M-Pesa integration (Daraja API)
- Rent collection tracking
- Payment history and receipts
- Arrears management

### 🛠️ Maintenance Tracking
- Submit maintenance requests with photos
- Status tracking (Pending → In Progress → Resolved)
- Automatic SMS notifications

### 📱 USSD Support
- Access system via USSD (*384*123#)
- Check rent balance
- Pay rent via M-Pesa
- Submit maintenance requests
- View lease information

### 📊 Analytics Dashboard
- Occupancy rates
- Revenue tracking
- Arrears monitoring
- Maintenance statistics
- Monthly trends

### 📬 Notifications
- SMS notifications (Twilio/Africa's Talking)
- Payment confirmations
- Rent reminders
- Maintenance updates

## Technology Stack

### Backend
- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Database:** MariaDB 10.11+ / MySQL 8.0+
- **ORM:** Prisma
- **Authentication:** JWT
- **Payment:** M-Pesa Daraja API
- **SMS:** Twilio / Africa's Talking
- **Containerization:** Docker

### Mobile
- **Framework:** Flutter 3.0+
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Charts:** FL Chart
- **HTTP:** Dio

## Project Structure

```
rentara/
├── backend/              # Node.js/Express backend
│   ├── src/
│   │   ├── config/       # Configuration files
│   │   ├── middleware/   # Express middleware
│   │   ├── routes/       # API routes
│   │   ├── services/     # Business logic
│   │   └── server.js     # Server entry point
│   ├── prisma/           # Prisma schema and migrations
│   ├── Dockerfile
│   └── docker-compose.yml
│
└── mobile/               # Flutter mobile app
    ├── lib/
    │   ├── core/         # Core functionality
    │   └── features/     # Feature modules
    └── pubspec.yaml
```

## Quick Start

### Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. Set up database:
   ```bash
   # Using Docker
   docker-compose up -d mariadb
   
   # Or create manually (MariaDB/MySQL)
   mysql -u root -p
   CREATE DATABASE rentara;
   CREATE USER 'rentara'@'localhost' IDENTIFIED BY 'rentara123';
   GRANT ALL PRIVILEGES ON rentara.* TO 'rentara'@'localhost';
   FLUSH PRIVILEGES;
   EXIT;
   ```

5. Run migrations:
   ```bash
   npx prisma migrate dev
   npx prisma generate
   ```

6. Seed database (optional):
   ```bash
   npm run prisma:seed
   ```

7. Start server:
   ```bash
   npm run dev
   ```

### Mobile App Setup

1. Navigate to mobile directory:
   ```bash
   cd mobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code:
   ```bash
   flutter pub run build_runner build
   ```

4. Update API URL in `lib/core/config/app_config.dart`

5. Run the app:
   ```bash
   flutter run
   ```

## Docker Deployment

Deploy the entire backend stack using Docker:

```bash
cd backend
docker-compose up -d
```

This will start:
- MariaDB database
- Backend API server

Access the API at `http://localhost:3000`

## API Documentation

See `backend/README.md` for detailed API endpoint documentation.

## Environment Configuration

### Backend (.env)
- Database connection
- JWT secret
- M-Pesa credentials
- SMS provider credentials
- File upload settings

### Mobile (app_config.dart)
- API base URL
- Feature flags

## Sample Credentials

After seeding the database:
- **Admin:** `+254712345678` / `admin123`
- **Caretaker:** `+254723456789` / `caretaker123`
- **Tenant:** `+254734567890` / `tenant123`

## USSD Access

Tenants can access the system via USSD:
- Dial: `*384*123#`
- Follow the menu prompts

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

ISC

## Support

For issues and questions, please open an issue on the repository.



