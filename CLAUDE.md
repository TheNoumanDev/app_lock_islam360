# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role & Standards

You are a **senior Flutter developer**. Follow these rules strictly:
- Write production-quality, bug-free code. No shortcuts, no TODOs left behind.
- Write **unit tests** for every service/model and **widget tests** for every new screen/widget.
- Run `flutter analyze` after changes to catch issues early.
- **Update documentation** (CLAUDE.md, README.md, docs/) with every code change — no exceptions.
- Follow the Figma design closely (`figma/src/app/`) for UI implementation.

## Project Overview

**Nafs Guard (App Lock: Islam360)** - A gentle reminder app that intercepts distracting apps and shows Islamic content (Quranic verses, Hadiths) to encourage reflection. Includes Quran reading, Hadith browsing, Prayer times, and Islamic alarms. Android-first development with native Kotlin implementation.

### Core Features
- **App Lock** - Intercept apps, show Ayat/Hadith reminder (not strict blocker)
- **Quran Section** - Read Quran with translations
- **Hadith Section** - Browse Hadith collection
- **Prayer Times** - Namaz timings
- **Alarms** - Islamic alarms with wakeup duas + check-ins
- **Noor Streak** - Track consecutive reflection days

## Build & Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Build debug APK
flutter build apk --debug

# Run all tests
flutter test

# Run a single test file
flutter test test/core/services/app_list_service_test.dart

# Run linting/analysis
flutter analyze
```

## Architecture

### Native Android Implementation (MethodChannel)

The app uses native Kotlin code instead of Flutter packages for reliability:

- **Flutter → Android communication**: `lib/core/services/native_service.dart` communicates with `MainActivity.kt` via MethodChannel
- **Native helpers** in `android/app/src/main/kotlin/.../native/`:
  - `AppListHelper.kt` - App listing via `PackageManager`
  - `AppMonitorHelper.kt` - Usage monitoring via `UsageStatsManager`
  - `OverlayHelper.kt` - Lock screen overlay via `WindowManager`
  - `AppLockAccessibilityService.kt` - Real-time app detection (primary method)
  - `AccessibilityHelper.kt` - Accessibility Service management

### Flutter Services Layer

Services in `lib/core/services/` wrap native functionality:
- `NativeService` - MethodChannel wrapper for all native calls
- `AppListService` - Get installed apps
- `AppMonitorService` - Monitor foreground app changes
- `OverlayService` - Show/hide lock screen overlay
- `AccessibilityService` - Manage accessibility service state

### App Detection Strategy

1. **Primary (ALWAYS PREFERRED)**: Accessibility Service (`AppLockAccessibilityService`) for instant, real-time app launch detection
2. **Fallback only**: UsageStats polling via `AppMonitorHelper` when accessibility not enabled by user

### Lock Screen Strategy

- **Current**: Native XML overlay (`lock_screen_overlay.xml`) via `OverlayHelper.kt`
- **Planned**: Flutter lock screen (`lib/features/app_lock/screens/lock_screen.dart`) with Ayat, streaks, dismiss option
- **Native → Flutter**: Use MethodChannel to trigger Flutter screen from Accessibility Service

### Project Structure

```
├── docs/                 # Documentation
│   ├── NATIVE_IMPLEMENTATION.md
│   └── ALARM_FEATURE.md  # Alarm implementation research & plan
├── figma/src/app/        # Figma design exports (React/TSX reference)
├── lib/
│   ├── core/
│   │   ├── constants/    # Theme, colors, fonts, strings, constants
│   │   ├── models/       # AppInfo, LockSettings
│   │   ├── providers/    # Riverpod providers (service_providers, onboarding_provider)
│   │   ├── router/       # GoRouter config (app_router, app_shell with bottom nav)
│   │   └── services/     # NativeService, AppListService, AppMonitorService, etc.
│   ├── data/local/       # StorageService (shared_preferences)
│   ├── features/
│   │   ├── alarm/        # Alarm screen (placeholder)
│   │   ├── app_lock/     # Lock screen UI
│   │   ├── app_selection/# App selection UI (Apps tab)
│   │   ├── home/         # Home screen + widgets (prayer card, streaks, quick actions)
│   │   ├── onboarding/   # 5-slide onboarding flow
│   │   ├── prayer_times/ # Prayer times with live countdown + Hijri date
│   │   ├── profile/      # Profile screen with achievements & settings
│   │   └── quran/        # Quran screen (placeholder)
│   └── main.dart         # ProviderScope + MaterialApp.router
└── android/.../native/   # Kotlin native helpers
```

## Android Permissions

Required permissions configured in `AndroidManifest.xml`:
- `QUERY_ALL_PACKAGES` - List installed apps (Android 11+)
- `PACKAGE_USAGE_STATS` - Monitor app usage
- `SYSTEM_ALERT_WINDOW` - Display overlay
- Accessibility Service - Real-time app detection

## Code Conventions

### Naming
- **Files**: `snake_case.dart` (e.g., `app_list_service.dart`)
- **Classes**: `PascalCase` (e.g., `AppListService`)
- **Variables/functions**: `camelCase` (e.g., `getInstalledApps()`)

### Dart/Flutter Style
- Use `const` constructors wherever possible
- Prefer named parameters for functions with 3+ parameters
- Use `late` or nullable types appropriately
- Add comments for complex logic
- Always handle errors gracefully with try-catch for async operations

### State Management (Riverpod)
- Use `flutter_riverpod` for all state management
- Use `AsyncNotifier` + `ref.keepAlive()` for cached data (Quran, Hadith)
- Use `lastUpdated` timestamp pattern: only fetch from Firestore if local cache is stale
- Use `StateNotifier` or `Notifier` for simple reactive state (lock state, streaks)
- Use `go_router` for navigation

### Testing
- Tests mirror `lib/` structure in `test/` directory
- Use descriptive test names: `test_shouldReturnListOfApps_whenGetInstalledAppsCalled()`
- Group related tests using `group()` blocks
- Unit tests for services/models, widget tests for UI components

## Development Approach

- **Incremental development**: Build and validate each phase before moving to the next
- **Android first**: Focus on Android implementation, iOS comes later
- **Fix issues immediately**: If something breaks, fix it before continuing
- **Real device testing**: Test on real Android devices for app lock features (not just emulator)
- **Update docs when code changes**: When modifying code, update relevant documentation:
  - `CLAUDE.md` - Architecture, conventions, strategies
  - `README.md` - Features, TODO list, implementation status
  - `docs/NATIVE_IMPLEMENTATION.md` - Native Android code changes
  - `docs/ALARM_FEATURE.md` - Alarm feature implementation

## Testing

- Test on real Android devices (emulators may not properly simulate all permissions)
- Mock `NativeService` in unit tests instead of native functionality
- Verify permissions are requested correctly
- Test app restart scenarios
