# Running Rentara Mobile App on Android Emulator

## Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Android Studio**
   - Download from: https://developer.android.com/studio
   - Install Android SDK and Android SDK Platform-Tools

3. **Android Emulator**
   - Open Android Studio
   - Go to Tools → Device Manager
   - Create a new virtual device (AVD)
   - Recommended: Pixel 5 or newer with API 30+

4. **Backend Server Running**
   - Make sure your backend is running on `http://localhost:3000`
   - The Android emulator uses `10.0.2.2` to access `localhost` on your host machine

## Setup Steps

### 1. Navigate to Mobile Directory

```bash
cd mobile
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Generate Code (Riverpod)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Verify Android Emulator is Running

```bash
flutter devices
```

You should see your Android emulator listed, for example:
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
```

### 5. Configure API URL

The `app_config.dart` is already configured for Android emulator:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
```

**Important:** 
- `10.0.2.2` is a special IP that the Android emulator uses to access `localhost` on your host machine
- Make sure your backend is running on `localhost:3000`

### 6. Run the App

```bash
flutter run
```

Or specify the device explicitly:
```bash
flutter run -d emulator-5554
```

## Troubleshooting

### Backend Connection Issues

**Problem:** App can't connect to backend

**Solutions:**
1. Verify backend is running:
   ```bash
   curl http://localhost:3000/health
   ```

2. Check firewall settings - ensure port 3000 is not blocked

3. Verify API URL in `app_config.dart`:
   - Android emulator: `http://10.0.2.2:3000/api`
   - Physical device: `http://YOUR_COMPUTER_IP:3000/api`

4. Check backend CORS settings - ensure it allows requests from the emulator

### Flutter Doctor Issues

Run `flutter doctor` to check for issues:

```bash
flutter doctor
```

Common fixes:
- **Android licenses:** `flutter doctor --android-licenses`
- **Missing Android SDK:** Install via Android Studio SDK Manager
- **Missing Java:** Install JDK 11 or higher

### Build Errors

**Clean and rebuild:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Riverpod Generation Errors

If you see errors about missing `.g.dart` files:

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Emulator Not Detected

1. Start Android Studio
2. Open Device Manager (Tools → Device Manager)
3. Start your emulator
4. Verify: `flutter devices`

## Testing the Connection

Once the app is running:

1. The app should show the splash screen
2. Navigate to login screen
3. Try logging in with sample credentials:
   - Phone: `+254712345678`
   - Password: `admin123`

## Switching Between Emulator and Physical Device

### For Android Emulator:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
```

### For Physical Device:
1. Find your computer's IP address:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`
   
2. Update `app_config.dart`:
   ```dart
   static const String apiBaseUrl = 'http://192.168.1.100:3000/api'; // Your IP
   ```

3. Ensure your phone and computer are on the same WiFi network

## Hot Reload

While the app is running:
- Press `r` in the terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## Next Steps

1. Test authentication flow
2. Test API connections
3. Test all features (dashboard, payments, maintenance, etc.)
4. Check console logs for any errors

## Additional Resources

- Flutter Documentation: https://flutter.dev/docs
- Android Emulator Guide: https://developer.android.com/studio/run/emulator
- Flutter DevTools: https://flutter.dev/docs/development/tools/devtools

