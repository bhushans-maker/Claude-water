# 🚀 AquaAlarm - Build Instructions

## Prerequisites (Install Once)

### 1. Install Flutter SDK
```bash
# Download Flutter for your OS:
# https://flutter.dev/docs/get-started/install

# For Linux/Mac:
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$PATH:~/flutter/bin"
flutter doctor  # Check setup
```

### 2. Install Android Studio
- Download: https://developer.android.com/studio
- Open → SDK Manager → Install Android SDK 34
- Install Android Build Tools 34.0.0

---

## Setup the Project

### Step 1: Copy local.properties
Rename `android/local.properties.template` → `android/local.properties`

Edit it with your actual paths:
```properties
flutter.sdk=/home/YOUR_USERNAME/flutter
sdk.dir=/home/YOUR_USERNAME/Android/Sdk
```

### Step 2: Add Real Audio Files (IMPORTANT!)
The placeholder `.mp3` files in `assets/audio/` need to be replaced with real audio.

Download free water/chime sounds from:
- https://freesound.org (search: water drop, chime, ocean)
- Replace each file keeping the same filename:
  - `gentle_flow.mp3`
  - `water_droplets.mp3`
  - `ocean_waves.mp3`
  - `crystal_bells.mp3`
  - `soft_chime.mp3`

### Step 3: Install Dependencies
```bash
cd aqua_alarm
flutter pub get
```

---

## Build the APK

### Debug APK (For Testing)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (For Use)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Install Directly on Phone (USB debugging on)
```bash
flutter install
```

---

## Android 12+ Permissions Setup (On Your Phone)

After installing, grant these permissions:
1. **Notifications** → Allow
2. **Alarms & Reminders** → Settings → Apps → AquaAlarm → Allow
3. **Display over other apps** → Settings → Apps → AquaAlarm → Allow
4. **Battery Optimization** → Settings → Battery → AquaAlarm → Unrestricted

---

## Features Summary

| Feature | Details |
|---------|---------|
| 💧 Water calculation | Uses gender, age, weight, height, weather |
| ⏰ Background alarm | Works even when app is killed (AlarmManager) |
| 🔔 Full-screen popup | Shows "Water Reminder" on lock screen |
| 🎵 Alarm tunes | 5 selectable water-themed tunes |
| 📳 Vibration | Loops until water is logged |
| 📊 Progress chart | Animated water bottle + weekly bar chart |
| 🌤️ Weather modes | Cold, Normal, Hot, Very Hot (+/- ml) |
| 🎨 Dual theme | Dark (default) + Light, toggle anytime |
| 📅 Schedule view | Ideal hourly drinking schedule |

---

## Project Structure
```
aqua_alarm/
├── lib/
│   ├── main.dart              # Entry point, alarm callback
│   ├── theme/app_theme.dart   # Light & Dark themes
│   ├── models/user_profile.dart
│   ├── providers/app_provider.dart  # State management
│   ├── services/
│   │   ├── alarm_service.dart       # AlarmManager scheduling
│   │   ├── audio_service.dart       # Alarm audio + vibration
│   │   └── notification_service.dart
│   ├── utils/water_calculator.dart  # Water intake formula
│   └── screens/
│       ├── splash_screen.dart
│       ├── setup_screen.dart        # First-time setup wizard
│       ├── home_screen.dart         # Main dashboard
│       ├── alarm_popup_screen.dart  # Full-screen alarm UI
│       ├── settings_screen.dart
│       └── schedule_screen.dart
├── android/
│   └── app/src/main/kotlin/com/aqua/alarm/
│       ├── MainActivity.kt          # Handles alarm intents
│       ├── AlarmReceiver.kt         # BroadcastReceiver
│       └── AlarmForegroundService.kt
└── assets/audio/                   # Replace with real MP3s!
```
