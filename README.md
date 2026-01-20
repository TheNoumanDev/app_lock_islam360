# App lock: Islam360

**Transform distractions into reminders of Allah**

An app lock that intercepts distracting apps and presents Islamic content (Quranic verses, Hadiths) based on your current emotional state, requiring reflection before unlocking.

**Company:** [theDumbNetwork](https://github.com/theDumbNetwork)

---

## Core Concept

When you try to open a restricted app (Instagram, TikTok, etc.):

1. **App Lock Screen**: Always appears when opening a restricted app
2. **Feeling Input** (optional, based on user preference):
   - **Text Input**: User can type their current feeling/scenario
   - **OR Predefined Options**: Scrollable list of predefined emotional states (Anxious, Ungrateful, Bored, Sad, Stressed, etc.)
3. **LLM Mapping**: Free/low-cost LLM maps user's feeling/scenario to relevant Ayat or Hadith
4. **Spiritual Content Display**: Shows the matched Quranic Ayat or Hadith with translation
5. **Reflection Timer**: 3-second countdown before "Done" button is enabled (ensures user reads the content)
6. **Streak Tracking**: Mark as complete to maintain Noor Streak (consecutive reflections)
7. **Password Lock** (optional): User can configure to require password after reading (for extra security)
8. **Emergency Skip**: Shake device to skip (for emergencies)

### Content Frequency

- **App Lock**: Appears every time user opens a restricted app
- **Ayat/Hadith Display**: User configurable frequency:
  - Once per day
  - Twice per day
  - Thrice per day
  - Or disabled (password only)

---

## Key Features

- **Intelligent Content Matching**: LLM-powered mapping of user feelings to relevant Islamic content
- **Flexible Input Methods**: Text input or predefined scrollable options
- **Noor Streak**: Track consecutive reflections (no skips)
- **Configurable Lock Modes**:
  - **Content + Password**: Show Ayat/Hadith + require password
  - **Password Only**: Skip content, just password protection
  - **Content Frequency**: Once/twice/thrice per day
- **Emergency Skip**: Shake device to bypass (for emergencies)
- **Session Timer**: Auto-lock after set duration (future feature)

---

## Tech Stack

### Core Packages
- `system_alert_window` - Android overlay for lock screen
- `flutter_background_service` - Background app monitoring
- `usage_stats` - Detect which app user clicked
- `shake` - Shake-to-skip gesture
- `isar` - Local storage (streaks, config, cached content)
- `supabase_flutter` - Backend database & auth (see Backend Choice below)

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

Based on [theDumbNetwork backend strategy](/Users/nouman/Development/Personal Projects/dumb_calculator/backend_choice.md):

### Primary Choice: Supabase (Postgres)

**Why Supabase:**
- **SQL for relational data**: Ayat/Hadith content, user streaks, app lock settings, content mappings
- **Predictable cost**: No per-document read billing (unlike Firebase)
- **Self-hostable**: Can migrate to self-hosted for ultra-low cost later
- **Edge Functions**: Serverless logic for LLM integration, content matching
- **Built-in Auth**: User authentication and session management

**Data Structure:**
- **Users**: Authentication, preferences, streaks
- **Content**: Ayat/Hadith database with translations, metadata
- **Mappings**: LLM-generated mappings of feelings → content
- **User Data**: Lock settings, frequency preferences, app lists

**Cost Estimate:**
- **Hosted Pro Plan**: ~$25/month (handles 100k+ MAUs)
- **Self-hosted (VPS)**: ~$15–20/month (for cost optimization later)

**Alternative Consideration:**
- **Local-first with sync**: Store content locally (Isar), sync user data to Supabase
- **Hybrid approach**: Content cached locally, user preferences synced to cloud

### Additional Services (Future)
- **Firebase Cloud Messaging (FCM)**: Push notifications (free)
- **Firebase Analytics**: Event tracking (free tier sufficient)

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
│   │   ├── supabase_client.dart       # Supabase client setup
│   │   └── repositories/
│   │       ├── content_repository.dart # Ayat/Hadith data
│   │       ├── user_repository.dart    # User data & streaks
│   │       └── settings_repository.dart # User preferences
│   └── repositories/
│       └── base_repository.dart        # Base repository interface
│
├── features/
│   ├── app_lock/
│   │   ├── screens/
│   │   │   ├── lock_screen.dart        # Main lock screen
│   │   │   └── password_screen.dart    # Password input
│   │   ├── widgets/
│   │   │   └── lock_overlay.dart       # Overlay widget
│   │   └── viewmodels/
│   │       └── lock_viewmodel.dart
│   │
│   ├── content_display/
│   │   ├── screens/
│   │   │   └── reflection_screen.dart # Ayat/Hadith display
│   │   ├── widgets/
│   │   │   ├── ayat_widget.dart
│   │   │   └── hadith_widget.dart
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
2. 🔄 **Core Lock Flow** - App lock screen with feeling input + content display
3. 🤖 **LLM Integration** - Map user feelings to Ayat/Hadith
4. ⚠️ **Battery Optimization** - Critical: Guide users to disable battery optimization
5. 📊 **Content Curation** - Store Ayat/Hadith in Supabase, ensure quality mappings
6. ⏱️ **Timer & Streak** - 3-second timer, streak tracking
7. 🔐 **Password Lock** - Optional password after content
8. 🍎 **iOS** - Implement after Android is stable

---

## Project TODO List - Implementation Roadmap

### Phase 1: Base Project Setup & Structure

#### 1.1 Project Foundation
- [ ] Update `pubspec.yaml` with required dependencies:
  - `system_alert_window` (Android overlay)
  - `flutter_background_service` (background monitoring)
  - `usage_stats` (app detection)
  - `permission_handler` (permissions)
  - `device_apps` (get installed apps list)
  - `shared_preferences` (local storage)
- [ ] Create base folder structure:
  ```
  lib/
  ├── core/
  │   ├── constants/
  │   ├── models/
  │   ├── services/
  │   └── utils/
  ├── data/
  │   └── local/
  ├── features/
  │   ├── app_lock/
  │   ├── app_selection/
  │   └── settings/
  └── main.dart
  ```
- [ ] Create base models:
  - `lib/core/models/app_info.dart` (app package name, name, icon)
  - `lib/core/models/lock_settings.dart` (locked apps list)
- [ ] Create base constants:
  - `lib/core/constants/app_constants.dart`
- [ ] Update `main.dart` to remove default Flutter template code

---

### Phase 2: Android App List Feature

#### 2.1 Get Installed Apps
- [ ] Add Android permissions to `android/app/src/main/AndroidManifest.xml`:
  - `QUERY_ALL_PACKAGES` (for Android 11+)
  - `GET_TASKS` or `PACKAGE_USAGE_STATS` (for usage stats)
- [ ] Create service: `lib/core/services/app_list_service.dart`
  - Function to fetch all installed apps using `device_apps`
  - Filter system apps (optional)
  - Return list of `AppInfo` models
- [ ] Test: Print installed apps list to console

#### 2.2 Display Apps List UI
- [ ] Create screen: `lib/features/app_selection/screens/app_selection_screen.dart`
  - Scaffold with AppBar
  - ListView/GridView to show apps
  - Each item: app icon, app name
  - Loading state while fetching
  - Error handling
- [ ] Create widget: `lib/features/app_selection/widgets/app_item_widget.dart`
  - Display app icon, name
  - Checkbox/switch for selection
- [ ] Update `main.dart` to navigate to `AppSelectionScreen`
- [ ] Test: Verify apps list displays correctly

---

### Phase 3: App Selection & Storage

#### 3.1 App Selection Logic
- [ ] Add selection state management to `AppSelectionScreen`
  - Track selected apps (Set<String> of package names)
  - Toggle selection on tap
  - Visual feedback for selected apps
- [ ] Add "Select All" / "Deselect All" button
- [ ] Add search/filter functionality (optional)
- [ ] Test: Verify selection works

#### 3.2 Local Storage for Selected Apps
- [ ] Create service: `lib/data/local/storage_service.dart`
  - Save selected apps list
  - Load selected apps list
  - Clear selected apps
- [ ] Integrate storage in `AppSelectionScreen`:
  - Save on selection change
  - Load on screen init
- [ ] Test: Verify selected apps persist after app restart

---

### Phase 4: Android App Lock Implementation

#### 4.1 Background Service Setup
- [ ] Add Android permissions:
  - `FOREGROUND_SERVICE`
  - `SYSTEM_ALERT_WINDOW` (draw over other apps)
  - `PACKAGE_USAGE_STATS` (usage stats)
- [ ] Create service: `lib/core/services/app_monitor_service.dart`
  - Initialize background service using `flutter_background_service`
  - Monitor app usage using `usage_stats`
  - Detect when locked app is opened
- [ ] Create Android native code for background service (if needed)
- [ ] Test: Verify service runs in background

#### 4.2 App Detection Logic
- [ ] Implement app detection in `app_monitor_service.dart`:
  - Poll or listen for foreground app changes
  - Check if current app is in locked apps list
  - Trigger lock screen when locked app detected
- [ ] Test: Log when locked app is detected

#### 4.3 Lock Screen Overlay
- [ ] Add `SYSTEM_ALERT_WINDOW` permission request flow
- [ ] Create service: `lib/core/services/overlay_service.dart`
  - Show overlay using `system_alert_window`
  - Hide overlay
  - Check permission status
- [ ] Create simple lock screen: `lib/features/app_lock/screens/lock_screen.dart`
  - Full-screen overlay
  - Text: "App Locked - This is a test lock screen"
  - Button: "Unlock" (for now, just dismisses overlay)
- [ ] Integrate: When locked app detected → show lock screen
- [ ] Test: Open locked app → lock screen appears

---

### Phase 5: Lock Screen Functionality

#### 5.1 Basic Lock Screen Features
- [ ] Update `lock_screen.dart`:
  - Display app name that was locked
  - Better UI (centered text, styling)
  - "Unlock" button (simple dismiss for now)
- [ ] Add unlock logic:
  - Dismiss overlay
  - Return to home screen or previous app
- [ ] Test: Verify lock screen shows and dismisses correctly

#### 5.2 Prevent App Access
- [ ] Ensure lock screen blocks app interaction:
  - Overlay should be non-dismissible (except via button)
  - Back button should not work
  - User cannot interact with locked app
- [ ] Test: Verify locked app is inaccessible

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

#### 7.1 Supabase Setup
- [ ] Create Supabase project
- [ ] Add `supabase_flutter` to `pubspec.yaml`
- [ ] Create: `lib/data/remote/supabase_client.dart`
  - Initialize Supabase client
  - Environment variables for keys
- [ ] Test: Verify connection to Supabase

#### 7.2 Database Schema
- [ ] Create tables:
  - `users` (auth, preferences)
  - `content` (Ayat/Hadith)
  - `user_streaks` (streak tracking)
  - `content_mappings` (feeling → content mappings)
- [ ] Set up Row Level Security (RLS) policies

#### 7.3 Authentication
- [ ] Implement user sign up/login
- [ ] Create auth service: `lib/core/services/auth_service.dart`
- [ ] Sync user preferences to Supabase

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
- [ ] Sync to Supabase

---

## Validation Checklist (Before Moving to Backend)

- [ ] App list displays correctly
- [ ] App selection works and persists
- [ ] Background service runs reliably
- [ ] Lock screen appears when locked app opens
- [ ] Lock screen blocks app access
- [ ] Unlock button works
- [ ] Permissions are requested properly
- [ ] App works after restart
- [ ] No crashes or major bugs
- [ ] Battery optimization guide shown

---

## Quick Start

```bash
flutter create app_lock_islam360
cd app_lock_islam360
flutter pub add system_alert_window flutter_background_service usage_stats permission_handler device_apps shared_preferences shake isar supabase_flutter
```

**Note:** Additional dependencies for Phase 1:
- `permission_handler` - Handle Android/iOS permissions
- `device_apps` - Get list of installed apps
- `shared_preferences` - Local storage for selected apps

---

## Critical Considerations

- **Battery Life**: Foreground service + constant app checking = battery drain. Must optimize.
- **User Education**: Tutorial screen showing how to disable battery optimization and grant permissions
- **Content Quality**: LLM must map feelings appropriately. Don't show punishment verses to someone who's sad. Curate carefully.
- **Privacy**: All content can be cached locally. User preferences synced to Supabase. No tracking of which apps are blocked.
- **LLM Costs**: Use free/low-cost models. Consider local models (Ollama) for offline capability.
- **Content Frequency**: Smart scheduling to respect user's "once/twice/thrice per day" preference

---

## License

TBD
