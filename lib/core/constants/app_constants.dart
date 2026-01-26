/// App-wide constants (sizes, durations, limits, etc.)
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;

  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2xl = 24.0;
  static const double radiusFull = 9999.0;

  // Icon Sizes
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;

  // Button Heights
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Durations (in milliseconds)
  static const int durationFast = 150;
  static const int durationNormal = 300;
  static const int durationSlow = 500;
  static const int durationVerySlow = 1000;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Debounce/Delay
  static const int debounceDelay = 300;
  static const int searchDebounceDelay = 500;

  // Limits
  static const int maxSelectedApps = 50; // Reasonable limit
  static const int minPasswordLength = 4;
  static const int maxPasswordLength = 20;

  // Storage Keys
  static const String storageKeyLockedApps = 'locked_apps';
  static const String storageKeyLockEnabled = 'lock_enabled';
  static const String storageKeySettings = 'app_settings';

  // App Detection
  static const int appDetectionInterval = 500; // milliseconds
  static const int backgroundServiceInterval = 1000; // milliseconds
}
