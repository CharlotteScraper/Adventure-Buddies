# Adventure Buddies — Build Guide

## Project Overview
A safe, ad-free, COPPA-friendly mobile game for preschoolers (2–5 years old).
Built with Flutter, targeting iOS (iPhone & iPad) and Android.

## Prerequisites
- **Flutter SDK** 3.0+ (recommended: latest stable from flutter.dev)
- **Dart SDK** (bundled with Flutter)
- **iOS:** Xcode 15+ (for iOS builds and App Store submission)
- **Android:** Android Studio or Android SDK 34+ (for Android builds)
- **CocoaPods** (for iOS plugin installation)

## Quick Start

```bash
# 1. Install dependencies
cd /home/team/shared/flutter_app
flutter pub get

# 2. iOS setup (on macOS)
cd ios && pod install && cd ..

# 3. Run on connected device or simulator
flutter run

# 4. Build for distribution
flutter build ios        # iOS (requires Apple Developer account)
flutter build apk        # Android
```

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # Root widget with Provider setup
│   ├── core/                        # Shared infrastructure
│   │   ├── constants/               # Colors, constants
│   │   ├── services/                # Audio, narration, haptic, storage
│   │   ├── theme/                   # Material3 theme
│   │   └── widgets/                 # Reusable UI components
│   ├── features/                    # Feature-first architecture
│   │   ├── onboarding/              # Welcome → Name → Buddy Customization
│   │   ├── world_map/               # World selection carousel
│   │   ├── world_detail/            # Activity list per world
│   │   ├── learning_activities/     # 4 interactive games
│   │   ├── real_world_missions/     # Physical movement activities
│   │   ├── rewards/                 # Sticker/badge collection
│   │   └── parent_dashboard/        # Stats + settings (locked)
│   └── data/                        # Data layer
│       ├── database/                # SQLite schema + migrations
│       ├── models/                  # Data models
│       └── repositories/           # CRUD operations
├── assets/
│   ├── images/                      # World themes, Buddy, icons
│   ├── sounds/                      # Music + SFX (TODO)
│   └── fonts/                       # Custom fonts (optional)
├── ios/                             # iOS Xcode project
│   ├── Runner/                      # App source, storyboards, Info.plist
│   ├── Flutter/                     # Flutter iOS framework stubs
│   └── Podfile                      # CocoaPods configuration
├── android/                         # Android Gradle project
│   ├── app/                         # App module
│   └── gradle/                      # Build configuration
├── pubspec.yaml                     # Flutter dependencies
└── PRIVACY_POLICY.md                # COPPA-compliant privacy policy
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management / DI |
| `sqflite` | Local SQLite database |
| `shared_preferences` | User settings storage |
| `audioplayers` | Sound effects + music |
| `google_fonts` | Fredoka One + Quicksand fonts |
| `path_provider` | Local file paths |
| `intl` | Date/time formatting |

## Database
SQLite database with 6 tables:
- `child_profiles` — Player profiles + buddy customization
- `world_progress` — Per-world star counts + unlock status
- `activity_progress` — Per-activity completion + star rating
- `mission_records` — Real World Mission tracking
- `reward_items` — Sticker/badge inventory
- `learning_sessions` — Play time tracking for dashboard

See `/home/team/shared/database/DATABASE_SCHEMA.md` for full schema.

## Asset Status

### ✓ Ready
- **Source code** — 35 Dart files, complete app shell + 4 games
- **Project config** — pubspec.yaml, theme, color palette
- **Documentation** — Database schema, privacy policy, build guide
- **iOS files** — Info.plist, storyboards, AppDelegate, Podfile
- **Android files** — build.gradle, manifest, MainActivity

### ⚠️ Needs Attention
- **Designer images** — Copy from `/home/team/shared/design/images/` to `assets/images/`
  (`buddy_default.png`, `world_forest_letters.png`, `world_number_beach.png`,
   `world_shape_city.png`, `world_feelings_garden.png`, `app_icon_concepts.png`)
- **Sound files** — Source per `/home/team/shared/design/SOUND_AND_ANIMATION.md`
- **`flutter pub get`** — Run on a machine with Flutter SDK
- **`pod install`** — Run on macOS for iOS build

## Build for App Store

### iOS
```bash
flutter build ios --release
```
Then open `ios/Runner.xcworkspace` in Xcode, configure signing, archive, and upload.

### Android
```bash
flutter build apk --release
```
APK will be at `build/app/outputs/flutter-apk/app-release.apk`

## COPPA Compliance
This app collects NO personal data. No analytics, no ads, no accounts.
Full privacy policy at `PRIVACY_POLICY.md`.

## Target Launch: July 11, 2026