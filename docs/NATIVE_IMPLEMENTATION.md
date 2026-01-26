# Native Android Implementation

Native Kotlin code replaces broken Flutter packages (`device_apps`, `usage_stats`, `system_alert_window`, `permission_handler`) via MethodChannel.

## Native Helpers (`android/.../native/`)

| File | Purpose | Replaces |
|------|---------|----------|
| `AppListHelper.kt` | Get installed apps via `PackageManager` | `device_apps` |
| `AppMonitorHelper.kt` | Monitor foreground app via `UsageStatsManager` | `usage_stats` |
| `OverlayHelper.kt` | Lock screen overlay via `WindowManager` | `system_alert_window` |
| `AppLockAccessibilityService.kt` | Real-time app detection (PRIMARY) | - |
| `AccessibilityHelper.kt` | Accessibility Service management | `permission_handler` |

## Flutter Services (`lib/core/services/`)

| Service | Purpose |
|---------|---------|
| `NativeService` | MethodChannel wrapper for all native calls |
| `AppListService` | Get installed apps |
| `AppMonitorService` | Monitor foreground app + trigger lock |
| `OverlayService` | Show/hide lock screen |
| `AccessibilityService` | Manage accessibility state |

## MethodChannel Methods

**App List:** `getInstalledApps`, `searchApps`, `getAppByPackageName`

**Monitoring:** `hasUsageStatsPermission`, `requestUsageStatsPermission`, `getForegroundAppPackageName`

**Overlay:** `hasOverlayPermission`, `requestOverlayPermission`, `showLockScreen`, `closeOverlay`, `isOverlayShowing`

**Accessibility:** `isAccessibilityServiceEnabled`, `requestAccessibilityServicePermission`, `syncLockedApps`, `syncLockEnabled`, `unlockApp`

## App Detection Strategy

1. **Primary (ALWAYS):** Accessibility Service - instant, real-time detection
2. **Fallback:** UsageStats polling - only when accessibility not enabled

## Lock Screen Strategy

- **Current:** Native XML overlay (`res/layout/lock_screen_overlay.xml`)
- **Planned:** Flutter lock screen with Ayat, streaks, dismiss (via MethodChannel callback)
