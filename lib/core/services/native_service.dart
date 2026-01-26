import 'package:flutter/services.dart';
import '../models/app_info.dart';

/// Service to communicate with native Android code via MethodChannel
/// This replaces broken packages (device_apps, usage_stats, system_alert_window)
class NativeService {
  static const MethodChannel _channel = MethodChannel('com.example.app_lock_islam360/native');

  // ==================== App List Methods ====================

  /// Get all installed apps
  static Future<List<AppInfo>> getInstalledApps({
    bool includeSystemApps = false,
  }) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getInstalledApps',
        {'includeSystemApps': includeSystemApps},
      );

      return result.map((app) {
        // Convert dynamic map to Map<String, dynamic>
        final Map<String, dynamic> appMap = Map<String, dynamic>.from(app as Map);
        return AppInfo.fromNativeMap(appMap);
      }).toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to get installed apps: ${e.message}');
    }
  }

  /// Search apps by name
  static Future<List<AppInfo>> searchApps(
    String query, {
    bool includeSystemApps = false,
  }) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'searchApps',
        {
          'query': query,
          'includeSystemApps': includeSystemApps,
        },
      );

      return result.map((app) {
        // Convert dynamic map to Map<String, dynamic>
        final Map<String, dynamic> appMap = Map<String, dynamic>.from(app as Map);
        return AppInfo.fromNativeMap(appMap);
      }).toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to search apps: ${e.message}');
    }
  }

  /// Get app by package name
  static Future<AppInfo?> getAppByPackageName(String packageName) async {
    try {
      final dynamic result = await _channel.invokeMethod(
        'getAppByPackageName',
        {'packageName': packageName},
      );

      if (result == null) return null;
      // Convert dynamic map to Map<String, dynamic>
      final Map<String, dynamic> appMap = Map<String, dynamic>.from(result as Map);
      return AppInfo.fromNativeMap(appMap);
    } on PlatformException catch (e) {
      throw Exception('Failed to get app: ${e.message}');
    }
  }

  // ==================== App Monitor Methods ====================

  /// Check if usage stats permission is granted
  static Future<bool> hasUsageStatsPermission() async {
    try {
      final bool result = await _channel.invokeMethod('hasUsageStatsPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Request usage stats permission
  static Future<void> requestUsageStatsPermission() async {
    try {
      await _channel.invokeMethod('requestUsageStatsPermission');
    } on PlatformException catch (e) {
      throw Exception('Failed to request permission: ${e.message}');
    }
  }

  /// Get current foreground app package name
  static Future<String?> getForegroundAppPackageName() async {
    try {
      final String? result = await _channel.invokeMethod('getForegroundAppPackageName');
      return result;
    } on PlatformException {
      return null;
    }
  }

  /// Check if specific app is in foreground
  static Future<bool> isAppInForeground(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod(
        'isAppInForeground',
        {'packageName': packageName},
      );
      return result;
    } on PlatformException {
      return false;
    }
  }

  // ==================== Overlay Methods ====================

  /// Check if overlay permission is granted
  static Future<bool> hasOverlayPermission() async {
    try {
      final bool result = await _channel.invokeMethod('hasOverlayPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Request overlay permission
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (e) {
      throw Exception('Failed to request overlay permission: ${e.message}');
    }
  }

  /// Show lock screen overlay
  static Future<void> showLockScreen(String appName) async {
    try {
      await _channel.invokeMethod('showLockScreen', {'appName': appName});
    } on PlatformException catch (e) {
      if (e.code == 'OVERLAY_PERMISSION_DENIED') {
        throw Exception('Overlay permission not granted. Please enable "Display over other apps" in Settings.');
      }
      throw Exception('Failed to show lock screen: ${e.message}');
    }
  }

  /// Close overlay
  static Future<void> closeOverlay() async {
    try {
      await _channel.invokeMethod('closeOverlay');
    } on PlatformException catch (e) {
      throw Exception('Failed to close overlay: ${e.message}');
    }
  }

  /// Check if overlay is showing
  static Future<bool> isOverlayShowing() async {
    try {
      final bool result = await _channel.invokeMethod('isOverlayShowing');
      return result;
    } on PlatformException {
      return false;
    }
  }

  // ==================== Accessibility Service Methods ====================

  /// Check if Accessibility Service is enabled
  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isAccessibilityServiceEnabled');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Request Accessibility Service permission
  static Future<void> requestAccessibilityServicePermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityServicePermission');
    } on PlatformException catch (e) {
      throw Exception('Failed to request accessibility permission: ${e.message}');
    }
  }

  /// Update locked apps list for Accessibility Service
  static Future<void> updateLockedAppsForAccessibility(List<String> apps) async {
    try {
      await _channel.invokeMethod('updateLockedAppsForAccessibility', {'apps': apps});
    } on PlatformException catch (e) {
      throw Exception('Failed to update locked apps: ${e.message}');
    }
  }

  /// Update lock enabled state for Accessibility Service
  static Future<void> updateLockEnabledForAccessibility(bool enabled) async {
    try {
      await _channel.invokeMethod('updateLockEnabledForAccessibility', {'enabled': enabled});
    } on PlatformException catch (e) {
      throw Exception('Failed to update lock enabled: ${e.message}');
    }
  }
}
