# Changelog

All notable changes to Nafs Guard (App Lock: Islam360) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- **Flutter Lock Screen Flow (Phase 6)**: Full lock screen experience replacing native XML overlay
  - `FeelingInputScreen` - asks user how they're feeling before showing content
  - `AyatDisplayScreen` - displays Quranic verse/Hadith with countdown timer and animations
  - Shake-to-skip emergency bypass via `ShakeService`
  - Islamic content system (`IslamicContent` model) mapping feelings to relevant Ayat/Hadith
- **Reverse MethodChannel** (Native → Flutter): Accessibility Service triggers Flutter lock screen
  - `triggerFlutterLockScreen()` in `MainActivity` launches Flutter activity from background
  - Pending lock data pattern for fresh activity starts
  - Intent extras cleared after handling to prevent stale lock screens on reopen
- **Navigation & Routing**: GoRouter-based full-screen lock routes (`/lock/feeling`, `/lock/ayat`)
- **App Minimize**: `minimizeApp()` via `moveTaskToBack(true)` returns user to locked app after unlock
- **Onboarding**: 6-slide onboarding flow with permissions slide (Usage Stats, Overlay, Accessibility, Notifications)
- **Home Screen**: Prayer card widget, Noor Streak tracker, quick actions grid
- **Prayer Times**: Live countdown, Hijri date display, prayer tiles with completion state
- **Profile Screen**: Achievements, settings, app info
- **Bottom Navigation**: 5-tab shell (Home, Apps, Alarms, Prayer, Quran) via `AppShell`
- **State Management**: Riverpod providers for services, onboarding state, locked apps
- **Storage**: `StorageService` with SharedPreferences for locked apps, lock settings, onboarding state
- **88 unit & widget tests** covering all screens, services, providers, and router

### Fixed
- Lock screen not appearing when Nafs Guard is in background (activity launch with proper intent flags)
- After unlock, user was taken to Nafs Guard home instead of staying on locked app (fixed with `minimizeApp`)
- Native XML overlay showing inconsistently instead of Flutter lock screen (improved `isFlutterReady` check)
- Permissions slide overflow on smaller screens (wrapped in `SingleChildScrollView`, reduced icon size)
- Stale lock screen showing when reopening app from recents (clear intent extras + navigate to home before minimize)

## [0.0.3] - 2026-02-01

### Added
- Figma design exports for UI reference (`figma/src/app/`)

## [0.0.2] - 2026-01-26

### Added
- Native Android overlay implementation via `OverlayHelper.kt` using `WindowManager`
- `AppLockAccessibilityService` for real-time app launch detection
- `AccessibilityHelper` for managing accessibility service state
- `AppMonitorHelper` for UsageStats-based fallback monitoring
- `AppListHelper` for listing installed apps via `PackageManager`
- Documentation: `NATIVE_IMPLEMENTATION.md`, `ALARM_FEATURE.md`

## [0.0.1] - 2026-01-20

### Added
- Initial project setup with Flutter
- Base project structure (`lib/core/`, `lib/features/`, `lib/data/`)
- `NativeService` with MethodChannel for Flutter ↔ Android communication
- `AppInfo` model and `AppListService`
- Android permissions configuration (`QUERY_ALL_PACKAGES`, `PACKAGE_USAGE_STATS`, `SYSTEM_ALERT_WINDOW`)
- `AppSelectionScreen` for selecting apps to lock
