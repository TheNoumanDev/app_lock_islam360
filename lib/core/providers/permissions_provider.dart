import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/native_service.dart';

/// State representing all required permissions
class PermissionsState {
  final bool accessibilityEnabled;
  final bool overlayEnabled;
  final bool notificationEnabled;
  final bool isLoading;

  const PermissionsState({
    this.accessibilityEnabled = false,
    this.overlayEnabled = false,
    this.notificationEnabled = false,
    this.isLoading = false,
  });

  /// Check if all required permissions are granted
  bool get allPermissionsGranted =>
      accessibilityEnabled && overlayEnabled && notificationEnabled;

  /// Check if minimum required permissions are granted (for app to function)
  bool get minimumPermissionsGranted =>
      accessibilityEnabled && overlayEnabled;

  PermissionsState copyWith({
    bool? accessibilityEnabled,
    bool? overlayEnabled,
    bool? notificationEnabled,
    bool? isLoading,
  }) {
    return PermissionsState(
      accessibilityEnabled: accessibilityEnabled ?? this.accessibilityEnabled,
      overlayEnabled: overlayEnabled ?? this.overlayEnabled,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider for managing app permissions state
final permissionsProvider =
    StateNotifierProvider<PermissionsNotifier, PermissionsState>((ref) {
  return PermissionsNotifier();
});

class PermissionsNotifier extends StateNotifier<PermissionsState> {
  PermissionsNotifier() : super(const PermissionsState());

  /// Check all permissions and update state
  Future<void> checkAllPermissions() async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await Future.wait([
        NativeService.isAccessibilityServiceEnabled(),
        NativeService.hasOverlayPermission(),
        NativeService.hasNotificationPermission(),
      ]);

      state = PermissionsState(
        accessibilityEnabled: results[0],
        overlayEnabled: results[1],
        notificationEnabled: results[2],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Request accessibility permission (opens system settings)
  Future<void> requestAccessibility() async {
    await NativeService.requestAccessibilityServicePermission();
    // Will need to re-check after user returns from settings
  }

  /// Request overlay permission (opens system settings)
  Future<void> requestOverlay() async {
    await NativeService.requestOverlayPermission();
    // Will need to re-check after user returns from settings
  }

  /// Request notification permission
  Future<void> requestNotification() async {
    await NativeService.requestNotificationPermission();
    // Re-check after request
    await Future.delayed(const Duration(milliseconds: 500));
    final granted = await NativeService.hasNotificationPermission();
    state = state.copyWith(notificationEnabled: granted);
  }

  /// Update accessibility permission state
  void updateAccessibility(bool enabled) {
    state = state.copyWith(accessibilityEnabled: enabled);
  }

  /// Update overlay permission state
  void updateOverlay(bool enabled) {
    state = state.copyWith(overlayEnabled: enabled);
  }

  /// Update notification permission state
  void updateNotification(bool enabled) {
    state = state.copyWith(notificationEnabled: enabled);
  }
}
