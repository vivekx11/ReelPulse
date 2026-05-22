# ScrollBattle 🎮

> Track Instagram Reels & YouTube Shorts. Compete with friends to scroll less.

---

## Setup Instructions

### 1. Firebase Setup (Required)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named **ScrollBattle**
3. Add an **Android app** with package name: `com.scrollbattle.scroll_battle`
4. Download `google-services.json` and replace `android/app/google-services.json`
5. Enable these Firebase services:
   - **Authentication** → Google Sign-In
   - **Firestore Database** → Start in production mode
   - **Cloud Storage**
   - **Cloud Messaging**

### 2. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

### 3. Add Fonts

Download and place in `assets/fonts/`:
- [Orbitron](https://fonts.google.com/specimen/Orbitron) — Regular, Bold
- [Inter](https://fonts.google.com/specimen/Inter) — Regular, Medium, Bold

### 4. Add Google Logo

Place `google_logo.png` in `assets/icons/` (download from Google Brand Resources).

### 5. Install Dependencies

```bash
flutter pub get
```

### 6. Run

```bash
flutter run
```

---

## Architecture

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── theme/           # Dark futuristic theme
│   ├── utils/           # Date, score helpers
│   └── services/        # GoRouter setup
├── data/
│   ├── models/          # UserModel, DailyStatsModel, etc.
│   ├── repositories/    # Firebase data access
│   └── providers/       # Riverpod providers
├── presentation/
│   ├── screens/         # Auth, Dashboard, Leaderboard, Friends, Profile
│   └── widgets/         # GlassCard, GradientButton, Charts, etc.
└── services/
    ├── native/          # Method channel bridge to Kotlin
    └── firebase/        # FCM notifications

android/app/src/main/kotlin/com/scrollbattle/scroll_battle/
├── MainActivity.kt                          # Method + Event channels
├── TrackingEventBus.kt                      # In-process event bus
└── services/
    ├── ScrollAccessibilityService.kt        # Reel/Short detection
    └── TrackingForegroundService.kt         # Background tracking
```

---

## Required Android Permissions

| Permission | Purpose |
|---|---|
| `SYSTEM_ALERT_WINDOW` | Floating overlay bubble |
| `PACKAGE_USAGE_STATS` | Screen time tracking |
| `BIND_ACCESSIBILITY_SERVICE` | Reel/Short scroll detection |
| `FOREGROUND_SERVICE` | Background tracking |
| `POST_NOTIFICATIONS` | Usage alerts |

---

## Key Features

- **Auto-detection** of Instagram Reels and YouTube Shorts via Accessibility Service
- **Real-time overlay bubble** showing live counts
- **Leaderboard** — global and friends-only, least/most scrolling
- **Addiction score** — calculated from reels + shorts + watch time
- **Streak system** and achievement badges
- **Dark futuristic UI** with glassmorphism and neon gradients
- **Secure Firestore rules** with anti-cheat caps

---

## Play Store Compliance Notes

- The Accessibility Service declaration includes a clear user-facing description
- No personal content (messages, photos) is read — only scroll events are counted
- All data is owned by the user and deletable
- The app does not collect data from other users without consent
