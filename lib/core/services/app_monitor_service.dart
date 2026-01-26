import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../constants/app_constants.dart';
import '../../data/local/storage_service.dart';
import 'native_service.dart';
import 'overlay_service.dart';
import 'accessibility_service.dart';

/// Service for monitoring apps in the foreground and triggering lock screen
class AppMonitorService {
  static AppMonitorService? _instance;
  final StorageService _storageService;
  final OverlayService _overlayService;
  AccessibilityLockService? _accessibilityService;
  Timer? _monitoringTimer;
  String? _lastDetectedApp;
  bool _isMonitoring = false;
  bool _isServiceRunning = false;
  bool _useAccessibilityService = false; // Toggle between methods

  AppMonitorService._(this._storageService, this._overlayService);

  /// Get singleton instance
  static Future<AppMonitorService> getInstance() async {
    _instance ??= AppMonitorService._(
      await StorageService.getInstance(),
      OverlayService(),
    );
    return _instance!;
  }

  /// Check if usage stats permission is granted
  Future<bool> hasUsageStatsPermission() async {
    final hasPermission = await NativeService.hasUsageStatsPermission();
    debugPrint('[AppMonitor] Usage Stats Permission: $hasPermission');
    return hasPermission;
  }

  /// Request usage stats permission
  /// Opens Android settings for user to grant permission
  Future<bool> requestUsageStatsPermission() async {
    debugPrint('[AppMonitor] Requesting Usage Stats Permission...');
    await NativeService.requestUsageStatsPermission();
    // Return true after a delay to allow user to grant permission
    // Actual permission check should be done separately
    return true;
  }

  /// Initialize and start background service
  Future<bool> startMonitoring() async {
    if (_isServiceRunning) {
      debugPrint('[AppMonitor] Monitoring already running');
      return true;
    }

    debugPrint('[AppMonitor] Starting monitoring...');
    try {
      // Check permissions
      final hasUsagePermission = await hasUsageStatsPermission();
      debugPrint('[AppMonitor] Usage Stats Permission: $hasUsagePermission');
      if (!hasUsagePermission) {
        debugPrint('[AppMonitor] ❌ Usage Stats Permission NOT granted');
        debugPrint('[AppMonitor] Requesting Usage Stats Permission...');
        await requestUsageStatsPermission();
        debugPrint('[AppMonitor] ⚠️ User needs to grant permission in Settings, then restart app');
        return false;
      }
      
      // Test if we can actually get data (permission might be granted but UsageStats empty)
      final testPackage = await NativeService.getForegroundAppPackageName();
      if (testPackage == null) {
        debugPrint('[AppMonitor] ⚠️ Permission granted but UsageStats is empty');
        debugPrint('[AppMonitor] This might mean:');
        debugPrint('[AppMonitor]   1. Permission was just granted - restart app');
        debugPrint('[AppMonitor]   2. UsageStats needs time to populate');
        debugPrint('[AppMonitor]   3. No apps have been used recently');
        // Continue anyway - might work after a moment
      } else {
        debugPrint('[AppMonitor] ✅ Permission working! Detected app: $testPackage');
      }

      // Initialize background service
      debugPrint('[AppMonitor] Configuring background service...');
      final service = FlutterBackgroundService();
      
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: false, // Don't auto-start, we'll start manually
          isForegroundMode: true,
          notificationChannelId: 'app_lock_monitor',
          initialNotificationTitle: 'App Lock Active',
          initialNotificationContent: 'Monitoring apps...',
          foregroundServiceNotificationId: 888,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onStart,
          onBackground: onIosBackground,
        ),
      );

      await service.startService();
      debugPrint('[AppMonitor] Background service started');
      // Note: startService() is async but doesn't return Future
      // Service will start in background
      _isServiceRunning = true;
      _isMonitoring = true;

      // Set lock enabled state to true when monitoring starts
      await _storageService.saveLockEnabled(true);
      debugPrint('[AppMonitor] Lock enabled state set to true');

      // Try to enable Accessibility Service (faster, more reliable)
      try {
        _accessibilityService = await AccessibilityLockService.getInstance();
        
        // Always sync lock state to native SharedPreferences (even if service not enabled yet)
        // This ensures when user enables Accessibility Service later, it reads the correct state
        final lockSettings = await _storageService.loadLockSettings();
        await _accessibilityService!.syncLockedApps(lockSettings.lockedApps);
        await _accessibilityService!.syncLockEnabled(true);
        debugPrint('[AppMonitor] Synced lock state to native SharedPreferences');
        
        final accessibilityEnabled = await _accessibilityService!.isAccessibilityServiceEnabled();
        if (accessibilityEnabled) {
          _useAccessibilityService = true;
          debugPrint('[AppMonitor] ✅ Using Accessibility Service for app locking (faster)');
          // Don't start UsageStats polling if Accessibility Service is active (avoid duplicates)
        } else {
          debugPrint('[AppMonitor] ⚠️ Accessibility Service not enabled, using UsageStats polling');
          debugPrint('[AppMonitor] Lock state synced - will work when user enables Accessibility Service');
          _useAccessibilityService = false;
          // Start local monitoring timer as backup
          _startLocalMonitoring();
          debugPrint('[AppMonitor] Local monitoring timer started');
        }
      } catch (e) {
        debugPrint('[AppMonitor] Error enabling Accessibility Service: $e');
        debugPrint('[AppMonitor] Falling back to UsageStats polling');
        _useAccessibilityService = false;
        // Start local monitoring timer as backup
        _startLocalMonitoring();
        debugPrint('[AppMonitor] Local monitoring timer started');
      }

      return true;
    } catch (e) {
      debugPrint('[AppMonitor] Error starting monitoring: $e');
      return false;
    }
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    debugPrint('[AppMonitor] Stopping monitoring...');
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    // Set lock enabled state to false when monitoring stops
    await _storageService.saveLockEnabled(false);
    debugPrint('[AppMonitor] Lock enabled state set to false');
    
    // Always sync disabled state to native SharedPreferences
    if (_accessibilityService != null) {
      await _accessibilityService!.syncLockEnabled(false);
      debugPrint('[AppMonitor] Synced disabled state to native SharedPreferences');
    }
    
    // Disable Accessibility Service if enabled
    if (_useAccessibilityService && _accessibilityService != null) {
      await _accessibilityService!.disableAccessibilityLock();
      _useAccessibilityService = false;
    }
    
    final service = FlutterBackgroundService();
    service.invoke('stopService');
    _isServiceRunning = false;
    debugPrint('[AppMonitor] Monitoring stopped');
  }

  /// Start local monitoring timer
  void _startLocalMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.appDetectionInterval),
      (timer) async {
        if (!_isMonitoring) {
          timer.cancel();
          return;
        }
        await _checkForegroundApp();
      },
    );
  }

  /// Check which app is currently in foreground
  Future<void> _checkForegroundApp() async {
    try {
      // Skip if Accessibility Service is active (it handles locking directly)
      if (_useAccessibilityService) {
        debugPrint('[AppMonitor] Accessibility Service is active, skipping UsageStats check');
        return;
      }

      // Get current foreground app using native service
      final currentPackage = await NativeService.getForegroundAppPackageName();

      // Skip if no package or same app as last check
      if (currentPackage == null || currentPackage.isEmpty) {
        debugPrint('[AppMonitor] No foreground app detected');
        return;
      }

      if (currentPackage == _lastDetectedApp) {
        // Same app, skip
        return;
      }

      debugPrint('[AppMonitor] Foreground app changed: $_lastDetectedApp -> $currentPackage');
      _lastDetectedApp = currentPackage;

      // Check if this app is locked
      final lockSettings = await _storageService.loadLockSettings();
      final lockedApps = lockSettings.lockedApps;
      debugPrint('[AppMonitor] Locked apps list: $lockedApps');
      final isLocked = lockSettings.isAppLocked(currentPackage);
      debugPrint('[AppMonitor] App $currentPackage is locked: $isLocked');
      
      if (isLocked) {
        debugPrint('[AppMonitor] 🔒 LOCKED APP DETECTED: $currentPackage - Showing lock screen...');
        // Show lock screen
        final shown = await _overlayService.showLockScreen(
          appName: currentPackage,
        );
        if (!shown) {
          debugPrint('[AppMonitor] ⚠️ Lock screen failed to show - likely missing overlay permission');
          debugPrint('[AppMonitor] User needs to grant "Display over other apps" permission');
        } else {
          debugPrint('[AppMonitor] ✅ Lock screen shown successfully');
        }
      } else {
        debugPrint('[AppMonitor] App $currentPackage is not locked, allowing access');
      }
    } catch (e) {
      debugPrint('[AppMonitor] ❌ Error checking foreground app: $e');
      // Error checking app, continue monitoring
    }
  }

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Check if Accessibility Service is enabled
  Future<bool> isAccessibilityServiceEnabled() async {
    if (_accessibilityService == null) {
      _accessibilityService = await AccessibilityLockService.getInstance();
    }
    return await _accessibilityService!.isAccessibilityServiceEnabled();
  }

  /// Request Accessibility Service permission (opens settings)
  Future<void> requestAccessibilityServicePermission() async {
    if (_accessibilityService == null) {
      _accessibilityService = await AccessibilityLockService.getInstance();
    }
    await _accessibilityService!.requestAccessibilityServicePermission();
  }

  /// Sync locked apps to Accessibility Service (if enabled)
  /// Call this whenever locked apps list changes
  Future<void> syncLockedAppsToAccessibility(Set<String> lockedApps) async {
    if (_useAccessibilityService && _accessibilityService != null) {
      await _accessibilityService!.syncLockedApps(lockedApps);
    }
  }
}

/// Background service entry point
/// Note: This is required by flutter_background_service but monitoring logic is handled by:
/// - Accessibility Service (primary, real-time app detection)
/// - Local timer in _startLocalMonitoring() (fallback when Accessibility Service disabled)
/// The service is mainly used to keep a foreground notification active.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }
  // Monitoring is handled by Accessibility Service or local timer, not here
}

/// iOS background handler (stub - iOS not yet implemented)
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}
