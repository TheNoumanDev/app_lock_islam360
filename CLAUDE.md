# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**App Lock: Islam360** - A Flutter app that intercepts distracting apps and shows Islamic content (Quranic verses, Hadiths) before unlocking. Android-first development with native Kotlin implementation for core functionality.

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

1. **Primary**: Accessibility Service (`AppLockAccessibilityService`) for instant app launch detection
2. **Fallback**: UsageStats polling via `AppMonitorHelper` when accessibility not enabled

### Project Structure

```
lib/
├── core/
│   ├── constants/    # Theme, colors, fonts, strings
│   ├── models/       # AppInfo, LockSettings
│   └── services/     # NativeService, AppListService, AppMonitorService, etc.
├── data/local/       # StorageService (shared_preferences)
├── features/
│   ├── app_lock/     # Lock screen UI
│   └── app_selection/# App selection UI
└── main.dart
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

### State Management
- Use getX for stateManagemetn properly, with cache whereever requried.
- Alwasy try to use cache with dataTime,a nd check if the firestore has any updated data base don lastUPdated, that hasn't fetched, then only fetche the data.

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

## Testing

- Test on real Android devices (emulators may not properly simulate all permissions)
- Mock `NativeService` in unit tests instead of native functionality
- Verify permissions are requested correctly
- Test app restart scenarios
