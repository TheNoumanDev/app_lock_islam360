/// Centralized string constants for the app
/// All UI text should be defined here - nothing hardcoded!
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // App Info
  static const String appName = 'App Lock: Islam360';
  static const String appTagline = 'Transform distractions into reminders of Allah';

  // Common Actions
  static const String done = 'Done';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String skip = 'Skip';
  static const String continue_ = 'Continue';
  static const String confirm = 'Confirm';
  static const String select = 'Select';
  static const String deselect = 'Deselect';
  static const String selectAll = 'Select All';
  static const String deselectAll = 'Deselect All';

  // App Selection Screen
  static const String selectApps = 'Select Apps to Lock';
  static const String selectAppsDescription = 'Choose the apps you want to protect with Islamic content';
  static const String noAppsSelected = 'No apps selected';
  static const String appsSelected = 'apps selected';
  static const String searchApps = 'Search apps...';
  static const String loadingApps = 'Loading apps...';
  static const String failedToLoadApps = 'Failed to load apps';
  static const String retry = 'Retry';
  static const String startAppLock = 'Start App Lock';
  static const String stopAppLock = 'Stop App Lock';
  static const String appLockActive = 'App Lock Active';
  static const String appLockInactive = 'App Lock Inactive';

  // Lock Screen
  static const String appLocked = 'App Locked';
  static const String unlock = 'Unlock';
  static const String testLockScreen = 'This is a test lock screen';
  static const String lockedAppName = 'Locked App';

  // Settings Screen
  static const String settings = 'Settings';
  static const String appLockEnabled = 'App Lock Enabled';
  static const String manageLockedApps = 'Manage Locked Apps';
  static const String lockedApps = 'Locked Apps';
  static const String noLockedApps = 'No apps are currently locked';
  static const String removeFromLock = 'Remove from Lock';

  // Permissions
  static const String permissionsRequired = 'Permissions Required';
  static const String permissionExplanation = 'This app needs certain permissions to function properly';
  static const String grantPermission = 'Grant Permission';
  static const String permissionDenied = 'Permission Denied';
  static const String permissionDeniedMessage = 'Please grant the required permissions in settings';

  // Errors
  static const String error = 'Error';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Try Again';
  static const String noInternetConnection = 'No internet connection';

  // Battery Optimization
  static const String batteryOptimization = 'Battery Optimization';
  static const String batteryOptimizationTitle = 'Disable Battery Optimization';
  static const String batteryOptimizationMessage = 'To ensure the app lock works reliably, please disable battery optimization for this app';
  static const String openSettings = 'Open Settings';

  // Empty States
  static const String emptyStateTitle = 'Nothing here yet';
  static const String emptyStateMessage = 'Get started by selecting some apps to lock';

  // Loading States
  static const String loading = 'Loading...';
  static const String pleaseWait = 'Please wait...';

  // Navigation
  static const String navHome = 'Home';
  static const String navApps = 'Apps';
  static const String navAlarms = 'Alarms';
  static const String navPrayer = 'Prayer';
  static const String navQuran = 'Quran';

  // Home Screen
  static const String homeGreeting = 'Assalamu Alaikum';
  static const String homeNextPrayer = 'Next Prayer';
  static const String homeContinueReading = 'Continue Reading';
  static const String homeNoorStreak = 'Noor Streak';
  static const String homeQuickActions = 'Quick Actions';
  static const String homeAppLockReflections = 'App Lock\nReflections';
  static const String homeNamazStreak = 'Namaz\nStreak';
  static const String homeAyatReadings = 'Ayat\nReadings';
  static const String homeDailyEngagement = 'Daily\nEngagement';
  static const String homeViewProfile = 'View Profile';

  // Onboarding
  static const String onboardingTitle1 = 'Lock Distracting Apps';
  static const String onboardingDesc1 =
      'Choose which apps to lock. Get inspired with Quran verses and Hadith before opening them. Configure locks to activate: every time, once/twice/thrice daily, or only during prayer times.';
  static const String onboardingTitle2 = 'Turn Distractions into Dhikr';
  static const String onboardingDesc2 =
      'When you open a locked app, share how you\'re feeling. We\'ll show you a relevant Ayat or Hadith to reflect on before continuing. Shake to skip in emergencies.';
  static const String onboardingTitle3 = 'Wake Up with Purpose';
  static const String onboardingDesc3 =
      'Set alarms that require mindful dismissal. Choose your method: read a dhikr and tap done, solve a simple math problem, slide to dismiss, or shake your phone.';
  static const String onboardingTitle4 = 'Read Quran Daily';
  static const String onboardingDesc4 =
      'Track your Quran reading progress. Always continue from where you left off. Build a consistent reading habit with streak tracking.';
  static const String onboardingTitle5 = 'Support the Mission';
  static const String onboardingDesc5 =
      'Help us keep this app ad-free and continuously improving. Your contribution helps spread Islamic knowledge.';
  static const String onboardingGetStarted = 'Get Started';
  static const String onboardingSubscribeNow = 'Subscribe Now';
  static const String onboardingContinueFree = 'Continue for free';
  static const String onboardingCancelAnytime = 'Cancel anytime • 7-day free trial';
  static const String onboardingPrice = '₹299/month';

  // Profile
  static const String profile = 'Profile';
  static const String profileAchievements = 'Achievements';
  static const String profileSettings = 'Settings';
  static const String profileNotifications = 'Notifications';
  static const String profileAppearance = 'Appearance';
  static const String profileAbout = 'About';
  static const String profilePrivacy = 'Privacy Policy';
  static const String profileTerms = 'Terms of Service';

  // Placeholder
  static const String comingSoon = 'Coming Soon';
  static const String comingSoonDesc = 'This feature is under development';

  // Prayer Times
  static const String prayerUpcoming = 'UPCOMING';
  static const String prayerUntil = 'until';
  static const String prayerFajr = 'Fajr';
  static const String prayerDhuhr = 'Dhuhr';
  static const String prayerAsr = 'Asr';
  static const String prayerMaghrib = 'Maghrib';
  static const String prayerIsha = 'Isha';
  static const String prayerHanafi = 'Hanafi';
  static const String prayerShafi = 'Shafi';

  // Onboarding Permissions Slide
  static const String onboardingTitlePermissions = 'Grant Permissions';
  static const String onboardingDescPermissions =
      'These permissions are required for the app to work properly. Tap each to grant access.';
  static const String permissionAccessibility = 'Accessibility Service';
  static const String permissionAccessibilityDesc =
      'Required to detect when you open locked apps and show reminders';
  static const String permissionOverlay = 'Display Over Apps';
  static const String permissionOverlayDesc =
      'Required to show the lock screen over other apps';
  static const String permissionNotification = 'Notifications';
  static const String permissionNotificationDesc =
      'Required to show reminders and keep the service running';
  static const String permissionGranted = 'Granted';
  static const String permissionNotGranted = 'Tap to grant';
  static const String permissionRequired = 'Required';
  static const String permissionOptional = 'Optional';

  // Lock Screen
  static const String lockHowFeeling = 'How are you feeling right now?';
  static const String lockWhyReaching = 'Why am I reaching for this app?';
  static const String lockOrChooseBelow = 'or choose from below';
  static const String lockQuranicVerse = 'QURANIC VERSE';
  static const String lockHadith = 'HADITH';
  static const String lockReflecting = 'Take a moment to reflect...';
  static const String lockReflectionComplete = 'Reflection complete';
  static const String lockShakeToSkip = 'Shake device to skip in emergencies';
}
