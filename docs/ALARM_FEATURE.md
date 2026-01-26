# Alarm Feature Implementation

## Overview

Add Islamic alarm functionality with wakeup duas, check-ins, and streak tracking. Synergizes with existing app lock infrastructure.

## Feasibility: ✅ HIGH

Existing app lock setup provides ~70% of required infrastructure.

## What We Already Have

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| Overlay permission | ✅ | `SYSTEM_ALERT_WINDOW` |
| Wake lock | ✅ | `WAKE_LOCK` |
| Foreground service | ✅ | `flutter_background_service` |
| Battery optimization bypass | ✅ | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` |
| Native Kotlin + MethodChannel | ✅ | Existing architecture |

## Required Permissions (Add to AndroidManifest.xml)

```xml
<!-- Alarm scheduling (Android 12+) -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />

<!-- Full-screen alarm notification (Android 14+) -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />

<!-- Reschedule alarms after reboot -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Notifications (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Alarm sound playback -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
```

## Android 14+ Requirements

Google restricted Full-Screen Intents (FSI) in Android 14/15:

1. **Apps must declare as "alarm app"** in Play Console
2. **`USE_FULL_SCREEN_INTENT`** permission required
3. **Full-screen notification** (not overlay) is the recommended approach
4. Check `canUseFullScreenIntent()` before showing

> "FSI is now restricted to critical use cases only - calling and alarm apps."

## Implementation Approach

### Option A: Native Kotlin (Recommended)

Consistent with existing architecture. Add to `android/.../native/`:

| File | Purpose |
|------|---------|
| `AlarmHelper.kt` | Schedule/cancel alarms via `AlarmManager` |
| `AlarmReceiver.kt` | `BroadcastReceiver` for alarm triggers |
| `AlarmNotificationService.kt` | Full-screen notification display |
| `BootReceiver.kt` | Reschedule alarms after device reboot |

### Option B: Flutter Packages

| Package | Pros | Cons |
|---------|------|------|
| [`alarm`](https://pub.dev/packages/alarm) | Simple, iOS+Android | Less control |
| [`android_alarm_manager_plus`](https://pub.dev/packages/android_alarm_manager_plus) | More control | Android only, needs extra permission handling |
| [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) | Full-screen intent support | Complex setup |

## Architecture

### Alarm Flow

```
1. User sets alarm in Flutter UI
       ↓
2. Flutter → MethodChannel → AlarmHelper.kt
       ↓
3. AlarmManager.setAlarmClock() schedules exact alarm
       ↓
4. At alarm time: AlarmReceiver receives broadcast
       ↓
5. AlarmNotificationService shows full-screen notification
       ↓
6. User sees: Wakeup Dua + Check-in options
       ↓
7. User action → Update streak → Dismiss
```

### Alarm Screen UI

```
┌─────────────────────────────────────┐
│         ALARM TRIGGERED             │
│     (Full-Screen Notification)      │
├─────────────────────────────────────┤
│                                     │
│      🌅 Fajr Time - 5:30 AM        │
│                                     │
│   ┌─────────────────────────────┐   │
│   │     Wakeup Dua              │   │
│   │  الحمد لله الذي أحيانا...    │   │
│   │  "All praise is to Allah    │   │
│   │   who gave us life..."      │   │
│   └─────────────────────────────┘   │
│                                     │
│   [ ] I read the dua ✓              │
│                                     │
│  ┌──────────┐    ┌──────────────┐   │
│  └──────────┘    └──────────────┘   │
│                                     │
│         🔥 Streak: 7 days           │
└─────────────────────────────────────┘
```

## MethodChannel Methods

```dart
// Schedule alarm
await NativeService.scheduleAlarm(
  id: 1,
  time: DateTime(2024, 1, 1, 5, 30),
  label: 'Fajr',
  repeatDays: [1, 2, 3, 4, 5, 6, 7], // Daily
  soundUri: 'asset://sounds/adhan.mp3',
);

// Cancel alarm
await NativeService.cancelAlarm(id: 1);

// Get scheduled alarms
List<Alarm> alarms = await NativeService.getScheduledAlarms();

// Check permissions
bool canSchedule = await NativeService.canScheduleExactAlarms();
bool canShowFSI = await NativeService.canUseFullScreenIntent();

// Request permissions
await NativeService.requestExactAlarmPermission();
await NativeService.requestFullScreenIntentPermission();
```

## Alarm vs App Lock Comparison

| Feature | App Lock | Alarm |
|---------|----------|-------|
| Trigger | Accessibility Service | AlarmManager |
| Display | `SYSTEM_ALERT_WINDOW` overlay | Full-screen notification |
| Lock screen | Yes (overlay) | Yes (FSI) |
| User action | Blocks until unlock | Optional snooze/dismiss |
| Permission | Overlay + Accessibility | Exact Alarm + FSI |

## Native Implementation Details

### AlarmHelper.kt

```kotlin
class AlarmHelper(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    fun scheduleAlarm(id: Int, triggerTime: Long, label: String) {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("alarm_id", id)
            putExtra("alarm_label", label)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Use setAlarmClock for alarm apps (shows alarm icon in status bar)
        val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerTime, pendingIntent)
        alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
    }

    fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else true
    }
}
```

### AlarmReceiver.kt

```kotlin
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra("alarm_id", -1)
        val label = intent.getStringExtra("alarm_label") ?: "Alarm"

        // Start notification service
        val serviceIntent = Intent(context, AlarmNotificationService::class.java).apply {
            putExtra("alarm_id", alarmId)
            putExtra("alarm_label", label)
        }
        context.startForegroundService(serviceIntent)
    }
}
```

### Full-Screen Notification

```kotlin
fun showAlarmNotification(alarmId: Int, label: String) {
    // Create full-screen intent
    val fullScreenIntent = Intent(context, AlarmActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_USER_ACTION
        putExtra("alarm_id", alarmId)
    }
    val fullScreenPendingIntent = PendingIntent.getActivity(
        context, alarmId, fullScreenIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val notification = NotificationCompat.Builder(context, ALARM_CHANNEL_ID)
        .setSmallIcon(R.drawable.ic_alarm)
        .setContentTitle(label)
        .setContentText("Time to wake up!")
        .setPriority(NotificationCompat.PRIORITY_MAX)
        .setCategory(NotificationCompat.CATEGORY_ALARM)
        .setFullScreenIntent(fullScreenPendingIntent, true)
        .setOngoing(true)
        .build()

    notificationManager.notify(alarmId, notification)
}
```

## Manifest Additions

```xml
<!-- Alarm Receiver -->
<receiver
    android:name=".native.AlarmReceiver"
    android:exported="false" />

<!-- Boot Receiver (reschedule alarms) -->
<receiver
    android:name=".native.BootReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>

<!-- Alarm Activity (full-screen) -->
<activity
    android:name=".AlarmActivity"
    android:showWhenLocked="true"
    android:turnScreenOn="true"
    android:exported="false" />

<!-- Alarm Notification Service -->
<service
    android:name=".native.AlarmNotificationService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="false" />
```

## Project Structure Addition

```
lib/features/
└── alarm/
    ├── models/
    │   └── alarm.dart              # Alarm model
    ├── screens/
    │   ├── alarm_list_screen.dart  # List of alarms
    │   ├── alarm_editor_screen.dart # Create/edit alarm
    │   └── alarm_trigger_screen.dart # Dua + check-in
    ├── widgets/
    │   ├── alarm_card.dart
    │   └── time_picker.dart
    └── services/
        └── alarm_service.dart      # Flutter wrapper for native

android/.../native/
├── AlarmHelper.kt
├── AlarmReceiver.kt
├── AlarmNotificationService.kt
└── BootReceiver.kt
```

## Synergy with Existing Features

| Shared Component | Usage |
|------------------|-------|
| Streak system | Morning check-ins build streaks |
| Islamic content | Morning duas, Fajr reminders |
| UI theme | Consistent lock screen styling |
| Native infrastructure | MethodChannel, Kotlin helpers |
| Firestore | Sync alarm settings, streak data |

## Implementation Phases

### Phase 1: Basic Alarm
- [ ] Add permissions to manifest
- [ ] Create `AlarmHelper.kt` - schedule/cancel
- [ ] Create `AlarmReceiver.kt` - handle trigger
- [ ] Add MethodChannel methods
- [ ] Basic Flutter alarm list UI

### Phase 2: Full-Screen Notification
- [ ] Create `AlarmNotificationService.kt`
- [ ] Implement full-screen intent
- [ ] Create `AlarmActivity` (or Flutter screen)
- [ ] Handle Android 14+ FSI restrictions

### Phase 3: Alarm Screen UI
- [ ] Wakeup dua display
- [ ] Check-in confirmation
- [ ] Snooze/dismiss actions
- [ ] Streak integration

### Phase 4: Polish
- [ ] Boot receiver (reschedule after reboot)
- [ ] Alarm sound selection
- [ ] Repeat patterns (daily, weekdays, custom)
- [ ] Prayer time integration

## References

- [Full-Screen Intent Notifications in Android 14 & 15 - droidcon](https://www.droidcon.com/2025/09/02/%F0%9F%9A%A8-full-screen-intent-fsi-notifications-in-android-14-15-what-changed-why-its-breaking-and-how-to-fix-it/)
- [Flutter Alarm Manager POC - GitHub](https://github.com/Applinx-Tech/Flutter-Alarm-Manager-POC)
- [alarm package - pub.dev](https://pub.dev/packages/alarm)
- [android_alarm_manager_plus - pub.dev](https://pub.dev/packages/android_alarm_manager_plus)
- [Schedule alarms - Android Developers](https://developer.android.com/develop/background-work/services/alarms)
- [AlarmManager API - Android Developers](https://developer.android.com/reference/android/app/AlarmManager)
