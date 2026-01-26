# Nafs Guard (App Lock: Islam360)

**Transform distractions into reminders of Allah**

A gentle reminder app that intercepts distracting apps and presents Islamic content (Quranic verses, Hadiths) to encourage reflection before continuing. Not a strict blocker - a spiritual companion.

**Company:** [theDumbNetwork](https://github.com/theDumbNetwork)

---

## App Features

| Feature | Description |
|---------|-------------|
| **App Lock** | Intercept distracting apps, show Islamic content as reminder |
| **Quran Section** | Read Quran with translations |
| **Hadith Section** | Browse authentic Hadith collection |
| **Prayer Times** | Namaz timings display |
| **Alarms** | Islamic alarms with wakeup duas + morning check-ins |
| **Ayat Reminder** | Show Quranic verse on locked app (configurable frequency) |
| **Feeling Input** | Select mood → LLM suggests relevant Ayat/Hadith |
| **Reflection Timer** | 3-second wait before dismiss (ensures reading) |
| **Noor Streak** | Track consecutive reflection days |
| **Emergency Skip** | Shake to bypass (emergencies only) |

---

## Core Concept

When you try to open a restricted app (Instagram, TikTok, etc.):

1. **Reminder Screen**: Appears when opening a restricted app
2. **Feeling Input** (optional):
   - **Text Input**: Type current feeling/scenario
   - **OR Predefined Options**: Select from emotional states (Anxious, Bored, Sad, Stressed, etc.)
3. **LLM Mapping**: Maps feeling to relevant Ayat or Hadith
4. **Content Display**: Shows matched Quranic Ayat or Hadith with translation
5. **Reflection Timer**: 3-second countdown before "Done" button enabled
6. **Streak Tracking**: Complete to maintain Noor Streak
7. **Emergency Skip**: Shake device to skip (for emergencies)

### Content Frequency

- **Reminder Screen**: Appears when opening restricted app
- **Ayat/Hadith Display**: User configurable:
  - Once per day
  - Twice per day
  - Thrice per day

---

## Key Features

- **Gentle Reminder**: Not a strict blocker - encourages reflection, then allows access
- **Quran & Hadith**: Full sections to read and browse Islamic content
- **Prayer Times**: Stay connected with Salah timings
- **Islamic Alarms**: Wake up with duas, morning check-ins for streaks
- **Intelligent Content**: LLM-powered mapping of feelings to relevant content
- **Noor Streak**: Track consecutive reflections (gamification)
- **Emergency Skip**: Shake device to bypass when needed

---

## Tech Stack

### Core Packages (Current)
- `permission_handler` - Handle Android/iOS permissions ✅
- `shared_preferences` - Local storage for selected apps ✅
- `flutter_background_service` - Background service (may be removable - see "Extra Code to Remove") ⚠️

### Native Android Implementation (Current)
- **Kotlin Native Code**:
  - `AppListHelper.kt` - App listing using `PackageManager` ✅
  - `AppMonitorHelper.kt` - App monitoring using `UsageStatsManager` ✅
  - `OverlayHelper.kt` - Overlay management using `WindowManager` ✅
  - `AppLockAccessibilityService.kt` - Accessibility Service for real-time app detection ✅
  - `AccessibilityHelper.kt` - Accessibility Service helper ✅
- **MethodChannel**: Flutter ↔ Android communication ✅

### Future Packages (Not Yet Integrated)
- `shake` - Shake-to-skip gesture
- `isar` or `hive` - Local storage (streaks, config, cached content)
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Firestore database (see Backend Choice below)
- `firebase_auth` - User authentication

### Content & APIs (Future Integrations)
- **Quran API**: [The-Quran-Project/Quran-API](https://github.com/The-Quran-Project/Quran-API) - Free, no rate limit
- **UmmahAPI**: [ummahapi.com](https://www.ummahapi.com/) - Qibla, prayer times, Hijri calendar, Asma ul Husna
- **AlQuran API**: [alquran-api.pages.dev](https://alquran-api.pages.dev/documentation) - Quranic content
- **Prayer Times API**: [PawanOsman/PrayerTimesAPI](https://github.com/PawanOsman/PrayerTimesAPI) - Prayer time calculations
- **Islamic API**: [islamicapi.com](https://islamicapi.com/doc/) - Comprehensive Islamic content API

### LLM Integration
- **Free/Low-Cost Options**: 
  - OpenAI GPT-3.5-turbo (cost-effective)
  - Anthropic Claude Haiku (low cost)
  - Local models via Ollama (free, offline)
  - Hugging Face Inference API (free tier available)

### Platform Notes
- **Android**: 
  - **AccessibilityService** (recommended): More reliable app detection, can attach overlays to windows (API 34+). Requires accessibility permission (similar UX to iOS Screen Time).
  - **Foreground Service + Overlay**: Uses `SYSTEM_ALERT_WINDOW` + `UsageStats` API. Easier to implement but requires sensitive permissions.
  - **Notification Bubbles**: More permission-friendly, but less flexible for full-screen interception.
  - **MediaProjection**: For screen capture scenarios, but requires per-session consent and higher overhead.
- **iOS**: No direct AccessibilityService equivalent. Options are:
  - **Family Controls + ManagedSettings** (primary): Requires Family Controls entitlement, can restrict apps but limited overlay capabilities. Similar permission UX to Android AccessibilityService.
  - **Screen Time API**: Limited access to usage data, requires user consent, cannot intercept app launches.
  - **MDM/Enterprise**: Only for supervised devices, not suitable for consumer apps.

---

## Backend Choice

### Primary Choice: Firebase (Firestore)

**Why Firebase over Supabase:**

| Factor | Firebase | Supabase |
|--------|----------|----------|
| **Starting cost** | $0 (generous free tier) | $25/month minimum for Pro |
| **Free tier** | 50k reads/day, 20k writes/day, 1GB storage | Limited, pauses after 1 week inactivity |
| **Scaling** | Pay only for what you use | Fixed monthly cost |
| **Ecosystem** | Auth, Analytics, FCM all integrated | Separate services needed |

**Why Firebase fits this app:**

1. **Zero cost to start** - No monthly fee until significant usage. With aggressive caching (Quran data, settings), free tier can handle thousands of users.

2. **Offline-first architecture** - This app is mostly cached:
   - Quran/Hadith content: Load once, cache forever (update only when `lastUpdated` changes)
   - Prayer times: Calculate locally or use free APIs
   - User settings: Sync only on change
   - Streaks: Sync daily

3. **Simple data model** - User settings, streaks, and cached content fit well in Firestore's document model. No complex SQL joins needed.

4. **Firebase ecosystem** - Auth, Analytics, FCM (push notifications) all have generous free tiers and integrate seamlessly.

5. **`lastUpdated` pattern** - Firestore efficiently supports fetching only updated data:
   ```dart
   // Only fetch if server has newer data
   firestore.collection('content')
     .where('lastUpdated', isGreaterThan: localLastUpdated)
   ```

**Data Architecture:**

```
Local (Isar/Hive)              Firebase (Firestore)
├── Quran cache ←───────────── content/{id} (fetch once, cache with lastUpdated)
├── Prayer times ←──────────── Calculate locally (adhan package) or free API
├── User settings ←─────────── users/{uid}/settings (sync on change)
├── Streaks ←───────────────── users/{uid}/streaks (sync daily)
└── LLM mappings ←──────────── mappings/{feeling} (cached locally)
```

**Firestore Collections:**
- `users/{uid}` - User profile, preferences
- `users/{uid}/streaks` - Streak history
- `users/{uid}/settings` - App lock settings, frequency preferences
- `content/quran` - Quran verses with translations (cached)
- `content/hadith` - Hadith collection (cached)
- `mappings/{feeling}` - LLM-generated feeling → content mappings

**Cost Estimate:**
- **Development/Launch**: $0 (free tier)
- **1k-10k MAU**: $0-5/month (with proper caching)
- **10k+ MAU**: Pay-as-you-go based on actual usage

### Firebase Services Used
- **Firestore**: Database for user data, content, mappings
- **Firebase Auth**: User authentication (email, Google, Apple)
- **Firebase Cloud Messaging (FCM)**: Push notifications (free)
- **Firebase Analytics**: Event tracking (free tier sufficient)

### When to Reconsider Supabase
- If complex SQL queries become necessary
- If self-hosting becomes a priority for cost at massive scale
- If relational data with many joins is needed

---

## Scalable Project Structure

The codebase is structured for easy feature additions. New APIs/features can be added by creating a new module/folder and importing the class.

```
lib/
├── core/
│   ├── constants/
│   │   └── api_endpoints.dart          # API endpoint constants
│   ├── models/
│   │   ├── mood.dart                   # Mood/feeling models
│   │   ├── content.dart                # Ayat/Hadith models
│   │   └── user_preferences.dart       # User settings models
│   ├── services/
│   │   ├── app_monitor_service.dart    # Background app detection
│   │   ├── overlay_service.dart        # Show lock screen overlay
│   │   ├── lock_service.dart           # Lock/unlock logic
│   │   └── llm_service.dart            # LLM integration for content mapping
│   └── utils/
│       ├── timer_utils.dart            # 3-second timer logic
│       └── streak_tracker.dart         # Streak calculation
│
├── data/
│   ├── local/
│   │   ├── isar_database.dart          # Local storage (Isar)
│   │   └── cache_manager.dart          # Content caching
│   ├── remote/
│   │   ├── firebase_service.dart      # Firebase/Firestore client setup
│   │   └── repositories/
│   │       ├── content_repository.dart # Ayat/Hadith data (with lastUpdated caching)
│   │       ├── user_repository.dart    # User data & streaks
│   │       └── settings_repository.dart # User preferences
│   └── repositories/
│       └── base_repository.dart        # Base repository interface
│
├── features/
│   ├── app_lock/
│   │   ├── screens/
│   │   │   └── lock_screen.dart        # Main reminder screen
│   │   ├── widgets/
│   │   │   └── lock_overlay.dart       # Overlay widget
│   │   └── viewmodels/
│   │       └── lock_viewmodel.dart
│   │
│   ├── quran/
│   │   ├── screens/
│   │   │   └── quran_screen.dart       # Quran reading
│   │   └── widgets/
│   │       └── ayat_widget.dart
│   │
│   ├── hadith/
│   │   ├── screens/
│   │   │   └── hadith_screen.dart      # Hadith browsing
│   │   └── widgets/
│   │       └── hadith_card.dart
│   │
│   ├── prayer_times/
│   │   ├── screens/
│   │   │   └── prayer_times_screen.dart # Namaz timings
│   │   └── widgets/
│   │       └── prayer_time_card.dart
│   │
│   ├── alarm/
│   │   ├── screens/
│   │   │   ├── alarm_list_screen.dart  # List of alarms
│   │   │   └── alarm_trigger_screen.dart # Dua + check-in
│   │   └── widgets/
│   │       └── alarm_card.dart
│   │
│   ├── content_display/
│   │   ├── screens/
│   │   │   └── reflection_screen.dart # Ayat/Hadith display (on lock)
│   │   └── viewmodels/
│   │       └── content_viewmodel.dart
│   │
│   ├── feeling_input/
│   │   ├── screens/
│   │   │   └── feeling_selection_screen.dart
│   │   ├── widgets/
│   │   │   ├── text_input_widget.dart  # Text input for feelings
│   │   │   └── predefined_options_widget.dart # Scrollable options
│   │   └── viewmodels/
│   │       └── feeling_viewmodel.dart
│   │
│   ├── settings/
│   │   ├── screens/
│   │   │   └── settings_screen.dart
│   │   └── viewmodels/
│   │       └── settings_viewmodel.dart
│   │
│   └── streak/
│       ├── widgets/
│       │   └── noor_streak_widget.dart
│       └── viewmodels/
│           └── streak_viewmodel.dart
│
├── api/
│   ├── quran_api/
│   │   ├── quran_api_client.dart       # The-Quran-Project API
│   │   └── models/
│   │       └── quran_response.dart
│   ├── ummah_api/
│   │   ├── ummah_api_client.dart       # UmmahAPI integration
│   │   └── models/
│   │       └── ummah_response.dart
│   ├── alquran_api/
│   │   ├── alquran_api_client.dart     # AlQuran API integration
│   │   └── models/
│   │       └── alquran_response.dart
│   ├── prayer_times_api/
│   │   ├── prayer_times_client.dart    # Prayer Times API
│   │   └── models/
│   │       └── prayer_times_response.dart
│   └── islamic_api/
│       ├── islamic_api_client.dart     # Islamic API integration
│       └── models/
│           └── islamic_api_response.dart
│
└── main.dart
```

### Adding New Features/APIs

To add a new API or feature:

1. **Create new folder** in `api/` or `features/` directory
2. **Create API client class** following the pattern:
   ```dart
   class NewApiClient {
     Future<Response> fetchData() async {
       // Implementation
     }
   }
   ```
3. **Import and use** in the relevant feature module
4. **Add to dependency injection** if needed

Example: Adding a new "Qibla Direction" feature:
```
lib/
└── features/
    └── qibla/
        ├── screens/
        │   └── qibla_screen.dart
        └── viewmodels/
            └── qibla_viewmodel.dart  # Uses ummah_api_client.dart
```

---

## Implementation Priority

1. ✅ **Android PoC** - Build proof of concept on Android first
2. 🔄 **Core Lock Flow** - Reminder screen with feeling input + content display
3. 🤖 **LLM Integration** - Map user feelings to Ayat/Hadith
4. ⚠️ **Battery Optimization** - Critical: Guide users to disable battery optimization
5. 📊 **Content Curation** - Store Ayat/Hadith in Firestore, ensure quality mappings
6. ⏱️ **Timer & Streak** - 3-second timer, streak tracking
7. 📖 **Quran & Hadith Sections** - Full reading/browsing experience
8. 🕌 **Prayer Times** - Namaz timings display
9. ⏰ **Alarm Feature** - Islamic alarms with wakeup duas & check-ins (see `docs/ALARM_FEATURE.md`)
10. 🍎 **iOS** - Implement after Android is stable

---

## Project TODO List - Implementation Roadmap

### Phase 1: Base Project Setup & Structure ✅

#### 1.1 Project Foundation ✅
- [x] Update `pubspec.yaml` with required dependencies:
  - `permission_handler` (permissions) ✅
  - `shared_preferences` (local storage) ✅
  - `flutter_background_service` (background monitoring) ✅ *Note: May be removable - see "Extra Code to Remove"*
- [x] Create base folder structure ✅
- [x] Create base models:
  - `lib/core/models/app_info.dart` ✅
  - `lib/core/models/lock_settings.dart` ✅
- [x] Create base constants:
  - `lib/core/constants/app_colors.dart` ✅
  - `lib/core/constants/app_fonts.dart` ✅
  - `lib/core/constants/app_strings.dart` ✅
  - `lib/core/constants/app_constants.dart` ✅
  - `lib/core/constants/app_theme.dart` ✅
- [x] Update `main.dart` to remove default Flutter template code ✅

---

### Phase 2: Android App List Feature ✅

#### 2.1 Get Installed Apps ✅
- [x] Add Android permissions to `android/app/src/main/AndroidManifest.xml`:
  - `QUERY_ALL_PACKAGES` (for Android 11+) ✅
  - `GET_TASKS` ✅
  - `PACKAGE_USAGE_STATS` (for usage stats) ✅
- [x] Create native Android implementation:
  - `AppListHelper.kt` - Native app listing using `PackageManager` ✅
  - `NativeService.dart` - Flutter MethodChannel wrapper ✅
- [x] Create service: `lib/core/services/app_list_service.dart` ✅
  - Function to fetch all installed apps using **native Android** ✅
  - Filter system apps (optional) ✅
  - Return list of `AppInfo` models ✅
- [x] Test: Apps list displays correctly ✅

#### 2.2 Display Apps List UI ✅
- [x] Create screen: `lib/features/app_selection/screens/app_selection_screen.dart` ✅
  - Scaffold with AppBar ✅
  - ListView to show apps ✅
  - Each item: app icon (placeholder), app name ✅
  - Loading state while fetching ✅
  - Error handling ✅
  - Search functionality ✅
- [x] Create widget: `lib/features/app_selection/widgets/app_item_widget.dart` ✅
  - Display app icon, name ✅
  - Checkbox for selection ✅
- [x] Update `main.dart` to navigate to `AppSelectionScreen` ✅
- [x] Test: Verified apps list displays correctly ✅

---

### Phase 3: App Selection & Storage ✅

#### 3.1 App Selection Logic ✅
- [x] Add selection state management to `AppSelectionScreen` ✅
  - Track selected apps (Set<String> of package names) ✅
  - Toggle selection on tap ✅
  - Visual feedback for selected apps ✅
- [x] Add "Select All" / "Deselect All" button ✅
- [x] Add search/filter functionality ✅
- [x] Test: Verified selection works ✅

#### 3.2 Local Storage for Selected Apps ✅
- [x] Create service: `lib/data/local/storage_service.dart` ✅
  - Save selected apps list ✅
  - Load selected apps list ✅
  - Clear selected apps ✅
  - Save/load lock enabled state ✅
- [x] Integrate storage in `AppSelectionScreen` ✅
  - Save on selection change ✅
  - Load on screen init ✅
- [x] Test: Verified selected apps persist after app restart ✅

---

### Phase 4: Android App Lock Implementation ✅

#### 4.1 Background Service Setup ✅
- [x] Add Android permissions:
  - `FOREGROUND_SERVICE` ✅
  - `FOREGROUND_SERVICE_DATA_SYNC` ✅
  - `SYSTEM_ALERT_WINDOW` (draw over other apps) ✅
  - `PACKAGE_USAGE_STATS` (usage stats) ✅
  - `WAKE_LOCK` ✅
  - `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` ✅
  - Accessibility Service permission ✅
- [x] Create service: `lib/core/services/app_monitor_service.dart` ✅
  - Monitor app usage using **native Android** `UsageStatsManager` ✅
  - Detect when locked app is opened ✅
  - Accessibility Service integration ✅
- [x] Create Android native code for app monitoring ✅
  - `AppMonitorHelper.kt` - Native usage stats monitoring ✅
  - `AppListHelper.kt` - Native app listing ✅
  - `OverlayHelper.kt` - Native overlay management ✅
  - `AppLockAccessibilityService.kt` - Accessibility Service for real-time app detection ✅
  - `AccessibilityHelper.kt` - Helper for Accessibility Service management ✅
  - `MainActivity.kt` - MethodChannel setup ✅
- [x] Test: Service structure ready ✅

#### 4.2 App Detection Logic ✅
- [x] Implement app detection in `app_monitor_service.dart` ✅:
  - Poll for foreground app changes using native service (backup) ✅
  - **Primary**: Accessibility Service for real-time app launch detection ✅
  - Check if current app is in locked apps list ✅
  - Trigger lock screen when locked app detected ✅
- [x] Native implementation: `AppMonitorHelper.kt` ✅
- [x] UI button to start/stop monitoring ✅
- [x] Permission request flows (Usage Stats, Overlay, Accessibility) ✅

#### 4.3 Lock Screen Overlay ✅
- [x] Add `SYSTEM_ALERT_WINDOW` permission request flow ✅
- [x] Create service: `lib/core/services/overlay_service.dart` ✅
  - Show overlay using **native Android** `WindowManager` ✅
  - Hide overlay ✅
  - Check permission status ✅
- [x] Create native lock screen overlay: `lock_screen_overlay.xml` ✅
  - Full-screen overlay with lock icon ✅
  - App name display ✅
  - "Unlock" button ✅
- [x] Temporary unlock mechanism ✅
  - App stays unlocked while in use ✅
  - Re-locks when app is switched away or killed/resumed ✅
- [x] Test: Open locked app → lock screen appears ✅

---

### Phase 5: Lock Screen Functionality ⚠️ (Partially Complete)

#### 5.1 Basic Lock Screen Features ⚠️
- [x] Native overlay displays app name that was locked ✅
- [x] Basic UI (centered text, lock icon, styling) ✅
- [x] "Unlock" button works ✅
- [x] Unlock logic:
  - Dismiss overlay ✅
  - App stays unlocked while in use ✅
  - Re-locks on app switch/kill/resume ✅
- [ ] **TODO**: Polish UI (better styling, colors from theme)
- [ ] **TODO**: Add Islamic content display (Quranic verses/Hadith)
- [x] Test: Verified lock screen shows and dismisses correctly ✅

#### 5.2 Prevent App Access ✅
- [x] Overlay blocks app interaction ✅
  - Overlay is non-dismissible (except via button) ✅
  - Touch events blocked ✅
  - App cannot be accessed while overlay is showing ✅
- [x] Test: Verified locked app is inaccessible ✅

---

### Phase 6: Polish & Validation

#### 6.1 Settings Screen
- [ ] Create: `lib/features/settings/screens/settings_screen.dart`
  - Button to go to app selection
  - Toggle to enable/disable app lock
  - Show list of currently locked apps
  - Remove apps from lock list
- [ ] Add navigation between screens

#### 6.2 Permission Handling
- [ ] Create permission request flow:
  - Check all required permissions
  - Request missing permissions
  - Show explanation dialogs
  - Handle permission denial gracefully
- [ ] Create: `lib/core/utils/permission_helper.dart`

#### 6.3 Battery Optimization
- [ ] Add battery optimization exemption request
- [ ] Create tutorial/guide screen for users
- [ ] Test: Verify app works after battery optimization disabled

#### 6.4 Testing & Bug Fixes
- [ ] Test on multiple Android versions (if possible)
- [ ] Test with different apps
- [ ] Fix any crashes or issues
- [ ] Verify lock screen appears reliably
- [ ] Test app restart scenarios

---

### Phase 7: Backend Setup (After Android Validation)

#### 7.1 Firebase Setup
- [ ] Create Firebase project in Firebase Console
- [ ] Add `firebase_core`, `cloud_firestore`, `firebase_auth` to `pubspec.yaml`
- [ ] Run `flutterfire configure` to generate Firebase config
- [ ] Create: `lib/data/remote/firebase_service.dart`
  - Initialize Firebase
  - Firestore instance setup
- [ ] Test: Verify connection to Firebase

#### 7.2 Firestore Collections
- [ ] Create collections:
  - `users/{uid}` (profile, preferences)
  - `users/{uid}/streaks` (streak history)
  - `users/{uid}/settings` (app lock settings)
  - `content/quran` (Ayat with translations, lastUpdated)
  - `content/hadith` (Hadith collection, lastUpdated)
  - `mappings/{feeling}` (feeling → content mappings)
- [ ] Set up Firestore Security Rules

#### 7.3 Authentication
- [ ] Implement user sign up/login (Firebase Auth)
- [ ] Create auth service: `lib/core/services/auth_service.dart`
- [ ] Sync user preferences to Firestore

#### 7.4 Caching Strategy
- [ ] Implement `lastUpdated` check before fetching content
- [ ] Cache Quran/Hadith data locally (Isar/Hive)
- [ ] Only fetch from Firestore if local cache is stale

---

### Phase 8: Content Features (Future)

#### 8.1 Feeling Input
- [ ] Create feeling input screen
- [ ] Text input and predefined options
- [ ] LLM integration for content mapping

#### 8.2 Content Display
- [ ] Integrate Quran/Hadith APIs
- [ ] Display content on lock screen
- [ ] Reflection timer (3 seconds)

#### 8.3 Streak Tracking
- [ ] Implement streak calculation
- [ ] Display Noor Streak widget
- [ ] Sync to Firestore

---

### Phase 9: Alarm Feature (Future)

> See detailed implementation plan: `docs/ALARM_FEATURE.md`

#### 9.1 Basic Alarm Setup
- [ ] Add alarm permissions to `AndroidManifest.xml`:
  - `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`
  - `USE_FULL_SCREEN_INTENT`
  - `RECEIVE_BOOT_COMPLETED`
  - `POST_NOTIFICATIONS`
- [ ] Create native helpers:
  - `AlarmHelper.kt` - Schedule/cancel alarms
  - `AlarmReceiver.kt` - Handle alarm triggers
  - `AlarmNotificationService.kt` - Full-screen notification
- [ ] Add MethodChannel methods for alarm scheduling

#### 9.2 Alarm UI
- [ ] Create alarm list screen
- [ ] Create alarm editor (time picker, repeat days)
- [ ] Create alarm trigger screen (wakeup dua + check-in)

#### 9.3 Full-Screen Notification
- [ ] Implement full-screen intent for lock screen display
- [ ] Handle Android 14+ FSI restrictions
- [ ] Add snooze/dismiss actions

#### 9.4 Integration
- [ ] Connect to streak system (morning check-ins)
- [ ] Add wakeup duas content
- [ ] Boot receiver for rescheduling after reboot
- [ ] Prayer time integration (optional)

---

## Validation Checklist (Before Moving to Backend)

- [x] App list displays correctly ✅
- [x] App selection works and persists ✅
- [x] Background service runs reliably ✅
- [x] Lock screen appears when locked app opens ✅
- [x] Lock screen blocks app access ✅
- [x] Unlock button works ✅
- [x] Permissions are requested properly ✅
- [x] App works after restart ✅
- [x] No crashes or major bugs ✅
- [ ] Battery optimization guide shown (TODO)
- [x] Accessibility Service works as primary detection method ✅
- [x] Temporary unlock mechanism works (stays unlocked while in use) ✅

**Status**: Core Android app lock functionality is **VALIDATED** ✅. Ready to proceed to Phase 6 (Polish) or Phase 7 (Backend).

---

## Quick Start

```bash
flutter create app_lock_islam360
cd app_lock_islam360
# Current packages (native Android implementation replaces device_apps, usage_stats, system_alert_window)
flutter pub add permission_handler shared_preferences flutter_background_service

# Future packages (add when needed)
flutter pub add firebase_core cloud_firestore firebase_auth isar shake
```

**Note:** Core functionality (app listing, monitoring, overlay) uses native Kotlin implementation via MethodChannel instead of Flutter packages for better reliability.

---

## Critical Considerations

- **Battery Life**: Foreground service + constant app checking = battery drain. Must optimize.
- **User Education**: Tutorial screen showing how to disable battery optimization and grant permissions
- **Content Quality**: LLM must map feelings appropriately. Don't show punishment verses to someone who's sad. Curate carefully.
- **Privacy**: All content can be cached locally. User preferences synced to Firestore. No tracking of which apps are blocked.
- **LLM Costs**: Use free/low-cost models. Consider local models (Ollama) for offline capability.
- **Content Frequency**: Smart scheduling to respect user's "once/twice/thrice per day" preference

---

## Current Implementation Status

### ✅ Completed Features

1. **Base Project Structure** ✅
   - Centralized constants (colors, fonts, strings, theme)
   - Models (`AppInfo`, `LockSettings`)
   - Project folder structure

2. **App Listing** ✅
   - Native Android implementation (`AppListHelper.kt`)
   - Flutter service (`AppListService`)
   - UI display with search functionality

3. **App Selection** ✅
   - Selection state management
   - Local storage persistence (`StorageService`)
   - Select All / Deselect All
   - Search/filter

4. **App Lock Core** ✅
   - Native Android overlay (`OverlayHelper.kt`)
   - Accessibility Service for real-time app detection (`AppLockAccessibilityService.kt`)
   - UsageStats polling as backup (`AppMonitorHelper.kt`)
   - Lock screen overlay with unlock button
   - Temporary unlock mechanism (stays unlocked while in use, re-locks on switch/kill/resume)

5. **Permission Handling** ✅
   - Usage Stats permission request
   - Overlay permission request
   - Accessibility Service permission request
   - User-friendly permission dialogs

6. **Testing** ✅
   - Unit tests for services
   - Widget tests for UI components
   - Real device testing

### ⚠️ Partially Complete

1. **Lock Screen UI** ⚠️
   - Basic overlay works ✅
   - Needs polish (better styling, theme integration)
   - Needs Islamic content integration (Quranic verses/Hadith)

2. **Settings Screen** ⚠️
   - Not yet implemented
   - Needed for better UX

### ❌ Remaining Work

1. **Phase 6: Polish & Validation**
   - Settings screen
   - Battery optimization guide
   - Comprehensive permission handling improvements
   - UI polish

2. **Phase 7: Backend Setup**
   - Firebase/Firestore initialization
   - Firestore collections setup
   - Firebase Auth integration
   - Caching strategy with lastUpdated

3. **Phase 8: Content Features**
   - Feeling input screen
   - LLM integration for content mapping
   - Quran/Hadith API integration
   - Reflection timer
   - Streak tracking

### 🗑️ Removed/Deprecated Code

1. **Deprecated packages** ✅
   - `device_apps` - Removed (replaced with native `PackageManager`)
   - `usage_stats` - Removed (replaced with native `UsageStatsManager`)
   - `system_alert_window` - Removed (replaced with native `WindowManager`)
   - `permission_handler` - Removed (permissions handled natively via Android APIs)

2. **`flutter_background_service`** ⚠️ (Kept for foreground notification)
   - **Status**: Kept but monitoring logic moved elsewhere
   - **Reason**: Provides persistent foreground notification to keep service alive
   - **Actual monitoring**: Done via Accessibility Service (primary) or local timer (fallback)

### 📝 Implementation Notes

- **Accessibility Service**: **ALWAYS PREFERRED** - Primary method for app detection (real-time, more reliable than polling).
- **UsageStats Polling**: Fallback only when Accessibility Service is not enabled by user.
- **Native Android Implementation**: App listing, monitoring, overlay all implemented in Kotlin for reliability.
- **Temporary Unlock**: Apps stay unlocked while in use, re-lock automatically when switched away or killed/resumed.
- **MethodChannel**: Flutter ↔ Android communication via `NativeService.dart` and `MainActivity.kt`.

### 🔜 Planned: Flutter Lock Screen

Currently using native XML overlay (`lock_screen_overlay.xml`). **Next step**: Replace with Flutter lock screen for richer UI:

**How to show Flutter screen from native Android:**
1. Accessibility Service detects locked app launch
2. Native sends event to Flutter via MethodChannel
3. Flutter shows full lock screen with:
   - Ayat/Hadith content
   - Streak display
   - Reflection timer
   - Dismiss/unlock option
4. Use `flutter_overlay_window` package OR launch Flutter as transparent Activity

**Files involved:**
- `lib/features/app_lock/screens/lock_screen.dart` - Flutter lock screen (to be enhanced)
- `AppLockAccessibilityService.kt` - Modify to call Flutter instead of native overlay

---

## License

TBD
