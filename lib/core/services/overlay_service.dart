import 'package:flutter/foundation.dart';
import 'native_service.dart';

/// Service for managing system overlay window (lock screen)
/// Now uses native Android implementation via MethodChannel
class OverlayService {
  /// Check if overlay permission is granted
  Future<bool> hasOverlayPermission() async {
    final hasPermission = await NativeService.hasOverlayPermission();
    debugPrint('[Overlay] Has overlay permission: $hasPermission');
    return hasPermission;
  }

  /// Request overlay permission
  Future<bool> requestOverlayPermission() async {
    debugPrint('[Overlay] Requesting overlay permission...');
    await NativeService.requestOverlayPermission();
    // Return true after requesting (actual permission check should be done separately)
    return true;
  }

  /// Show lock screen overlay
  /// 
  /// Displays a full-screen overlay with the lock screen content
  /// Uses native Android WindowManager to show overlay
  Future<bool> showLockScreen({
    required String appName,
  }) async {
    debugPrint('[Overlay] Attempting to show lock screen for: $appName');
    try {
      // Check permission first
      var hasPermission = await hasOverlayPermission();
      if (!hasPermission) {
        debugPrint('[Overlay] No overlay permission, requesting...');
        await requestOverlayPermission();
        // Wait a moment for user to grant permission
        await Future.delayed(const Duration(milliseconds: 500));
        // Check again after requesting
        hasPermission = await hasOverlayPermission();
        if (!hasPermission) {
          debugPrint('[Overlay] ❌ Overlay permission still not granted');
          debugPrint('[Overlay] User needs to grant "Display over other apps" permission in Settings');
          return false;
        }
        debugPrint('[Overlay] ✅ Overlay permission granted!');
      }

      // Double-check permission before showing
      if (!hasPermission) {
        debugPrint('[Overlay] ❌ Cannot show lock screen: No overlay permission');
        return false;
      }

      // Show the native lock screen overlay
      debugPrint('[Overlay] Calling native showLockScreen for: $appName');
      await NativeService.showLockScreen(appName);
      
      // Verify it was actually shown
      final isShowing = await NativeService.isOverlayShowing();
      if (isShowing) {
        debugPrint('[Overlay] ✅ Lock screen shown successfully');
        return true;
      } else {
        debugPrint('[Overlay] ❌ Lock screen call succeeded but overlay is not showing');
        return false;
      }
    } catch (e) {
      debugPrint('[Overlay] ❌ Error showing lock screen: $e');
      return false;
    }
  }

  /// Hide lock screen overlay
  Future<bool> hideLockScreen() async {
    debugPrint('[Overlay] Hiding lock screen...');
    try {
      await NativeService.closeOverlay();
      debugPrint('[Overlay] ✅ Lock screen hidden');
      return true;
    } catch (e) {
      debugPrint('[Overlay] ❌ Error hiding lock screen: $e');
      return false;
    }
  }

  /// Check if overlay is currently visible
  Future<bool> get isOverlayVisible async {
    final isShowing = await NativeService.isOverlayShowing();
    debugPrint('[Overlay] Is overlay showing: $isShowing');
    return isShowing;
  }
}
