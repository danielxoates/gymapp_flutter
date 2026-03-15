# Gym Tracker

A cross-platform Flutter fitness tracking app that lets you log workouts, monitor progress, and visualise your training stats — all stored locally on your device with no account required.

---

## Table of Contents

- [Features](#features)
  - [Dashboard](#dashboard)
  - [Exercise Library](#exercise-library)
  - [Workout Logger](#workout-logger)
  - [Workout History](#workout-history)
  - [Exercise Progress](#exercise-progress)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Clone & Run](#clone--run)
  - [Building for Production](#building-for-production)
- [Project Structure](#project-structure)
- [Contributing](#contributing)

---

## Features

### Dashboard

The home screen gives you an at-a-glance overview of your fitness activity.

- **Personalised greeting** — changes between morning / afternoon / evening.
- **Streak counter** — consecutive days with at least one logged workout (🔥).
- **Quick stats** (horizontally scrollable cards):
  - Total workouts logged
  - Workouts completed this week (out of 7)
  - Total sets performed
  - Total volume lifted (formatted as kg, K, or M)
- **Muscle group distribution** — colour-coded progress bars showing how many sets you have done per muscle group (Chest, Back, Shoulders, Legs, Arms, Core, Cardio).
- **Recent workouts** — a quick preview of your last few sessions showing name, date, duration, and exercises.
- **Personal records** 🏆 — horizontally scrollable cards for your top 6 all-time heaviest lifts per exercise.
- **Pull-to-refresh** to reload all statistics.

---

### Exercise Library

Browse, search, and manage the built-in exercise database.

- **56 built-in exercises** spanning 8 muscle groups and 7 equipment categories.
- **Real-time search** — filter by exercise name as you type.
- **Muscle group filter** — All, Chest, Back, Shoulders, Legs, Arms, Core, Cardio.
- **Category filter** — All, Barbell, Dumbbell, Cable, Machine, Bodyweight, Cardio.
- **Custom exercises** — tap the ➕ button to add your own exercise, choosing a name, muscle group, and category. Custom exercises can also be deleted.
- Each exercise card shows its name, muscle group, equipment category, and a colour-coded icon.

---

### Workout Logger

Create and track a workout in real time.

- **Automatic timer** starts the moment you open a new workout and displays elapsed time (MM:SS).
- **Workout name** — editable title; defaults to "Workout" if left blank.
- **Exercise management**:
  - Add any exercise from the full library (filterable by muscle group while adding).
  - Log multiple sets per exercise, each with **weight (kg)** and **reps**.
  - Edit or delete individual sets.
  - Reorder exercises within the workout.
- **Finish workout** — saves the session to history with a confirmation prompt.
- **In-progress protection** — if you navigate away mid-workout, your data is preserved and the workout resumes when you return.
- Supports **editing previously saved workouts**.

---

### Workout History

Review every session you have ever logged.

- Full chronological list of workouts, grouped by month and year.
- Each card shows:
  - Workout name and timestamp (day, date, time)
  - Duration, total sets, and total volume (kg)
  - All exercises with weight × reps notation and colour-coded muscle groups
- **Edit** any past workout to correct mistakes.
- **Delete** workouts with a confirmation dialog.
- Friendly empty-state message when no workouts exist yet.

---

### Exercise Progress

Tap any exercise in the library to open its dedicated progress screen and review your historical performance for that movement.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Dart) |
| Minimum Dart SDK | 3.11.0 |
| Local storage | [`shared_preferences`](https://pub.dev/packages/shared_preferences) ^2.3.0 |
| Charts | [`fl_chart`](https://pub.dev/packages/fl_chart) ^0.69.0 |
| Date formatting | [`intl`](https://pub.dev/packages/intl) ^0.19.0 |
| Icons | [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) ^1.0.8 |
| Linting | [`flutter_lints`](https://pub.dev/packages/flutter_lints) ^6.0.0 |

**Platform support:** Android · iOS · Web · Windows · macOS · Linux

All data is stored on-device via `SharedPreferences`. No backend or account is required.

---

## Installation

### Prerequisites

| Tool | Version |
|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.11.0 or later |
| Dart SDK | Bundled with Flutter |
| Android Studio | For Android builds |
| Xcode (macOS only) | For iOS / macOS builds |

Verify your Flutter installation:

```bash
flutter doctor
```

---

### Clone & Run

```bash
# 1. Clone the repository
git clone https://github.com/danielxoates/gymapp_flutter.git
cd gymapp_flutter

# 2. Fetch dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# Target a specific platform
flutter run -d android   # Android device / emulator
flutter run -d ios       # iOS simulator (macOS only)
flutter run -d chrome    # Web (Chrome)
flutter run -d windows   # Windows desktop
flutter run -d macos     # macOS desktop
flutter run -d linux     # Linux desktop
```

While the app is running you can use the following shortcuts in the terminal:

| Key | Action |
|---|---|
| `r` | Hot reload |
| `R` | Hot restart |
| `q` | Quit |

---

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS archive (macOS only)
flutter build ipa --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## Project Structure

```
gymapp_flutter/
├── lib/
│   ├── main.dart                          # App entry point & bottom-tab navigation
│   ├── theme.dart                         # Centralised dark theme (AppTheme)
│   ├── screens/
│   │   ├── dashboard_screen.dart          # Stats overview & quick actions
│   │   ├── exercises_screen.dart          # Exercise library, search & custom exercises
│   │   ├── workout_screen.dart            # Real-time workout logging
│   │   ├── history_screen.dart            # Past workout browser
│   │   └── exercise_progress_screen.dart  # Per-exercise history & progress
│   ├── data/
│   │   ├── exercises.dart                 # Exercise models & 56 built-in exercises
│   │   └── storage.dart                   # SharedPreferences persistence layer
│   └── components/
│       └── ui.dart                        # Reusable UI components (AppCard, StatCard…)
├── test/                                  # Unit & widget tests
├── android/                               # Android platform project
├── ios/                                   # iOS platform project
├── web/                                   # Web platform project
├── windows/                               # Windows platform project
├── macos/                                 # macOS platform project
├── linux/                                 # Linux platform project
├── pubspec.yaml                           # Dependencies & app metadata
└── analysis_options.yaml                  # Lint configuration
```

---

## Contributing

1. Fork the repository and create a feature branch.
2. Make your changes and ensure `flutter analyze` passes with no issues.
3. Run the test suite: `flutter test`.
4. Open a pull request describing your changes.
