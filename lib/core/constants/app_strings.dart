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
}
