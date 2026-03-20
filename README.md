# DataF1 — Flutter App

> Formula 1 telemetry interpretation and insight system — Flutter mobile frontend

DataF1 is **not** an F1 stats app. It is a telemetry interpretation system that converts raw F1 data into visual graphs and plain-English AI summaries that any fan can understand. This repo is the Flutter mobile app that users interact with.

---

## Tech Stack

| Concern | Library | Version |
|---|---|---|
| Framework | Flutter / Dart | 3.19.0 / 3.3.0 |
| State Management | flutter_bloc | 8.1.3 |
| Networking | Dio | 5.4.0 |
| Charting | fl_chart | 0.66.0 |
| Routing | go_router | 13.2.0 |
| Token Storage | flutter_secure_storage | 9.0.0 |
| Fonts | google_fonts (Barlow) | 6.2.1 |
| Loading States | shimmer | 3.0.0 |

---

## Project Structure

```
dataf1-flutter/
├── lib/
│   ├── main.dart                    # Entry point — system UI, orientation lock
│   ├── app.dart                     # MaterialApp.router with AuthBloc at root
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_colors.dart      # Single source of truth for all colors
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Full dark ThemeData — Barlow typography
│   │   ├── network/
│   │   │   └── dio_client.dart      # Dio singleton, auth + error interceptors
│   │   ├── router/
│   │   │   └── app_router.dart      # go_router — all routes, auth guard
│   │   └── widgets/
│   │       ├── loading_shimmer.dart # Shimmer skeletons for all loading states
│   │       └── main_shell.dart      # Bottom navigation shell
│   └── features/
│       ├── auth/                    # Login, Register, AuthBloc, AuthRepository
│       ├── home/                    # Home screen, race selection (Block 2)
│       ├── telemetry/               # Telemetry graph + AI summary (Block 3)
│       ├── predictions/             # Race predictions (Block 5)
│       └── profile/                 # User profile, saved drivers, logout
├── test/                            # Widget and BLoC tests
├── android/                         # Android platform config
├── ios/                             # iOS platform config
└── pubspec.yaml                     # Dependencies
```

Each feature follows the same internal structure:
```
feature/
├── bloc/       # BLoC: event, state, bloc files
├── data/       # Repository: API calls and local storage
└── view/       # Screens: UI only, no business logic
```

---

## Local Setup

### Prerequisites
- Flutter 3.19.0 (`flutter --version` to check)
- Dart 3.3.0
- iOS Simulator (Mac) or Android Emulator
- DataF1 backend running locally or on Render

### Steps

```bash
# 1. Clone the project
git clone https://github.com/YOUR_USERNAME/dataf1-flutter.git
cd dataf1-flutter

# 2. Install dependencies
flutter pub get

# 3. Set up environment
# Create a .env file in the project root:
echo "API_BASE_URL=http://YOUR_MAC_IP:8000" > .env
# Use your local network IP, not localhost (for simulator)
# Find it with: ipconfig getifaddr en0

# 4. Run the app
flutter run
```

> ⚠️ When running on iOS Simulator, use your Mac's local network IP (e.g. `192.168.1.6:8000`) not `localhost:8000`. The simulator's localhost is not your Mac.

---

## Architecture — BLoC Pattern

Every feature is strictly separated into three layers:

```
View (Widget)
    │  dispatches events
    ▼
BLoC
    │  calls repository methods
    ▼
Repository
    │  makes HTTP calls via Dio
    ▼
FastAPI Backend
```

**Rules:**
- Widgets contain UI and event dispatches only — no business logic
- BLoCs call repositories, never Dio directly
- Every data-loading screen implements exactly 4 states: Loading (shimmer), Success, Empty, Error

---

## Design System

All colors are in `lib/core/constants/app_colors.dart`. Never use hardcoded hex values.

| Token | Hex | Usage |
|---|---|---|
| `AppColors.background` | `#0F0F0F` | Main scaffold background |
| `AppColors.surface` | `#1A1A1A` | Cards, bottom sheets |
| `AppColors.primary` | `#FF1500` | F1 red — buttons, active states, accents |
| `AppColors.textPrimary` | `#FFFFFF` | Main text |
| `AppColors.textSecondary` | `#888888` | Labels, hints |

**Typography:** Barlow Condensed (headings, italic bold) + Barlow (body, labels)

**Loading states:** Always use shimmer — never `CircularProgressIndicator`

**Theme:** Dark only. No light theme. No `Colors.white` anywhere.

---

## Navigation

All navigation uses `go_router`. Never use `Navigator.push`.

| Route | Screen | Auth Required |
|---|---|---|
| `/home` | Home + race selection | No |
| `/telemetry` | Telemetry graph + AI summary | No |
| `/predictions` | Race predictions | No |
| `/profile` | User profile + logout | **Yes** |
| `/login` | Login screen | No |
| `/register` | Register screen | No |

The go_router guard redirects unauthenticated users from `/profile` to `/login` automatically.

---

## Development Commands

```bash
# Get dependencies
flutter pub get

# Analyze for errors and warnings
flutter analyze

# Run tests
flutter test

# Run on specific device
flutter run -d "iPhone 16"

# Run on Chrome (web)
flutter run -d chrome

# Build iOS release
flutter build ios --release

# Build Android release
flutter build apk --release
```

`flutter analyze` must return zero errors before any feature is considered complete.

---

## Error Messages

Consistent error strings used across all screens:

| Situation | Message |
|---|---|
| No telemetry data | `"Data not available for selected parameters"` |
| API / network failure | `"Unable to load data. Tap to retry"` |
| Offline, cache available | `"You're offline. Showing cached data"` |
| Offline, no cache | `"You are offline"` |
| Server error | `"Server error. Try again"` |
| Auth required | `"Login required"` |
| Session expired | `"Session expired. Please log in again"` |

---

## Build Status

| Block | Feature | Status |
|---|---|---|
| 0 | App scaffold — theme, routing, BLoC structure | ✅ Complete |
| 1 | Authentication — login, register, JWT, token refresh | ✅ Complete |
| 2 | Home screen + race selection flow | ✅ Complete |
| 3 | Telemetry graph + AI insight summary | ✅ Complete |
| 4 | Race results + driver comparison | ⏳ Pending |
| 5 | Race predictions | ⏳ Pending |
| 6 | Profile, saved preferences + polish | ⏳ Pending |
