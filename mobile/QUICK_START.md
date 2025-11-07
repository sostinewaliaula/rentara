# Quick Start - Run on Android Emulator

## Prerequisites Check

1. ✅ Flutter installed: `flutter --version`
2. ✅ Android Studio with emulator running
3. ✅ Backend server running on `localhost:3000`

## Quick Steps

### 1. Start Backend (if not running)
```bash
cd backend
npm run dev
```

### 2. Start Android Emulator
- Open Android Studio
- Tools → Device Manager
- Click ▶️ to start your emulator

### 3. Run Flutter App
```bash
cd mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## That's It! 🎉

The app should now launch on your Android emulator.

**Test Login:**
- Phone: `+254712345678`
- Password: `admin123`

## Common Issues

**"No devices found"**
→ Start Android emulator first, then run `flutter devices`

**"Connection refused"**
→ Make sure backend is running on `localhost:3000`

**Build errors**
→ Run: `flutter clean && flutter pub get`


