# Rentara Mobile App

Flutter mobile application for the Rentara rental housing management system.

## Setup

1. Install Flutter SDK (3.0.0 or higher)
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (for Riverpod):
   ```bash
   flutter pub run build_runner build
   ```

4. Update API base URL in `lib/core/config/app_config.dart`:
   - For Android emulator: `http://10.0.2.2:3000/api`
   - For iOS simulator: `http://localhost:3000/api`
   - For physical device: `http://YOUR_COMPUTER_IP:3000/api`

5. Run the app:
   ```bash
   flutter run
   ```

## Features

- Authentication (Login/Register)
- Role-based dashboards (Admin, Caretaker, Tenant)
- Unit management
- Payment processing via M-Pesa
- Maintenance request tracking
- Notifications
- Dark/Light theme support

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── providers/       # Riverpod providers
│   ├── router/          # Navigation routing
│   ├── services/        # API services
│   └── theme/           # App theming
├── features/
│   ├── auth/           # Authentication screens
│   ├── dashboard/      # Dashboard screens
│   ├── maintenance/    # Maintenance screens
│   ├── notifications/  # Notifications screens
│   ├── payments/       # Payment screens
│   ├── profile/        # Profile screens
│   ├── splash/         # Splash screen
│   └── units/          # Unit management screens
└── main.dart           # App entry point
```




