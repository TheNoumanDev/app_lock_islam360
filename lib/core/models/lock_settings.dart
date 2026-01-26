/// Model representing app lock settings
class LockSettings {
  final Set<String> lockedApps; // Set of package names
  final bool isLockEnabled;
  final DateTime? lastUpdated;

  const LockSettings({
    required this.lockedApps,
    this.isLockEnabled = true,
    this.lastUpdated,
  });

  /// Create LockSettings with empty locked apps
  factory LockSettings.empty() {
    return LockSettings(
      lockedApps: {},
      isLockEnabled: false,
      lastUpdated: DateTime.now(),
    );
  }

  /// Create LockSettings from JSON
  factory LockSettings.fromJson(Map<String, dynamic> json) {
    return LockSettings(
      lockedApps: Set<String>.from(json['lockedApps'] as List? ?? []),
      isLockEnabled: json['isLockEnabled'] as bool? ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  /// Convert LockSettings to JSON
  Map<String, dynamic> toJson() {
    return {
      'lockedApps': lockedApps.toList(),
      'isLockEnabled': isLockEnabled,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Check if an app is locked
  bool isAppLocked(String packageName) {
    return isLockEnabled && lockedApps.contains(packageName);
  }

  /// Add an app to locked list
  LockSettings addLockedApp(String packageName) {
    final updatedApps = Set<String>.from(lockedApps)..add(packageName);
    return LockSettings(
      lockedApps: updatedApps,
      isLockEnabled: isLockEnabled,
      lastUpdated: DateTime.now(),
    );
  }

  /// Remove an app from locked list
  LockSettings removeLockedApp(String packageName) {
    final updatedApps = Set<String>.from(lockedApps)..remove(packageName);
    return LockSettings(
      lockedApps: updatedApps,
      isLockEnabled: isLockEnabled,
      lastUpdated: DateTime.now(),
    );
  }

  /// Toggle lock enabled state
  LockSettings toggleLock() {
    return LockSettings(
      lockedApps: lockedApps,
      isLockEnabled: !isLockEnabled,
      lastUpdated: DateTime.now(),
    );
  }

  /// Copy with method for easy updates
  LockSettings copyWith({
    Set<String>? lockedApps,
    bool? isLockEnabled,
    DateTime? lastUpdated,
  }) {
    return LockSettings(
      lockedApps: lockedApps ?? this.lockedApps,
      isLockEnabled: isLockEnabled ?? this.isLockEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'LockSettings(lockedApps: ${lockedApps.length}, isLockEnabled: $isLockEnabled)';
  }
}
