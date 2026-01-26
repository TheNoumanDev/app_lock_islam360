/// Model representing an installed app on the device
class AppInfo {
  final String packageName;
  final String appName;
  final String? iconPath;
  final bool isSystemApp;

  const AppInfo({
    required this.packageName,
    required this.appName,
    this.iconPath,
    this.isSystemApp = false,
  });

  /// Create AppInfo from JSON
  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      iconPath: json['iconPath'] as String?,
      isSystemApp: json['isSystemApp'] as bool? ?? false,
    );
  }

  /// Create AppInfo from native Android map (includes iconBase64)
  factory AppInfo.fromNativeMap(Map<String, dynamic> map) {
    return AppInfo(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      iconPath: map['iconBase64'] as String?, // Native returns base64, we store it as iconPath
      isSystemApp: map['isSystemApp'] as bool? ?? false,
    );
  }

  /// Convert AppInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'iconPath': iconPath,
      'isSystemApp': isSystemApp,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppInfo && other.packageName == packageName;
  }

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() {
    return 'AppInfo(packageName: $packageName, appName: $appName, isSystemApp: $isSystemApp)';
  }
}
