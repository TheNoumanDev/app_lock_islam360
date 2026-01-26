import 'package:flutter/foundation.dart';
import 'native_service.dart';
import '../../data/local/storage_service.dart';

/// Service for managing Accessibility Service for app locking
/// This provides faster, more reliable app locking than UsageStats polling
class AccessibilityLockService {
  static AccessibilityLockService? _instance;
  final StorageService _storageService;

  AccessibilityLockService._(this._storageService);

  /// Get singleton instance
  static Future<AccessibilityLockService> getInstance() async {
    _instance ??= AccessibilityLockService._(
      await StorageService.getInstance(),
    );
    return _instance!;
  }

  /// Check if Accessibility Service is enabled
  Future<bool> isAccessibilityServiceEnabled() async {
    final enabled = await NativeService.isAccessibilityServiceEnabled();
    debugPrint('[Accessibility] Service enabled: $enabled');
    return enabled;
  }

  /// Request Accessibility Service permission
  Future<void> requestAccessibilityServicePermission() async {
    debugPrint('[Accessibility] Requesting Accessibility Service permission...');
    await NativeService.requestAccessibilityServicePermission();
    debugPrint('[Accessibility] Permission request sent - user needs to enable in Settings');
  }

  /// Enable Accessibility Service for app locking
  /// This syncs the locked apps list and enables the service
  Future<bool> enableAccessibilityLock() async {
    debugPrint('[Accessibility] Enabling Accessibility Service lock...');
    
    // Check if service is enabled
    final isEnabled = await isAccessibilityServiceEnabled();
    if (!isEnabled) {
      debugPrint('[Accessibility] ⚠️ Service not enabled, requesting permission...');
      await requestAccessibilityServicePermission();
      return false; // User needs to enable it manually
    }

    // Get locked apps and sync to native
    final lockSettings = await _storageService.loadLockSettings();
    await syncLockedApps(lockSettings.lockedApps);
    // Always sync true when enabling (we're enabling it now)
    await syncLockEnabled(true);

    debugPrint('[Accessibility] ✅ Accessibility Service lock enabled');
    return true;
  }

  /// Disable Accessibility Service lock
  Future<void> disableAccessibilityLock() async {
    debugPrint('[Accessibility] Disabling Accessibility Service lock...');
    await syncLockEnabled(false);
    debugPrint('[Accessibility] ✅ Accessibility Service lock disabled');
  }

  /// Sync locked apps list to native Accessibility Service
  Future<void> syncLockedApps(Set<String> lockedApps) async {
    try {
      await NativeService.updateLockedAppsForAccessibility(lockedApps.toList());
      debugPrint('[Accessibility] Synced ${lockedApps.length} locked apps to native service');
    } catch (e) {
      debugPrint('[Accessibility] ❌ Error syncing locked apps: $e');
    }
  }

  /// Sync lock enabled state to native Accessibility Service
  Future<void> syncLockEnabled(bool enabled) async {
    try {
      await NativeService.updateLockEnabledForAccessibility(enabled);
      debugPrint('[Accessibility] Synced lock enabled state: $enabled');
    } catch (e) {
      debugPrint('[Accessibility] ❌ Error syncing lock enabled: $e');
    }
  }
}
