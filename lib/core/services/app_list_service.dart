import '../models/app_info.dart';
import 'native_service.dart';

/// Service for fetching and managing installed apps
/// Now uses native Android implementation via MethodChannel
class AppListService {
  /// Get all installed apps on the device
  /// 
  /// Returns a list of [AppInfo] objects representing installed apps.
  /// Optionally filters out system apps if [includeSystemApps] is false.
  /// 
  /// Throws an exception if the operation fails.
  Future<List<AppInfo>> getInstalledApps({
    bool includeSystemApps = false,
  }) async {
    try {
      return await NativeService.getInstalledApps(includeSystemApps: includeSystemApps);
    } catch (e) {
      throw Exception('Failed to get installed apps: $e');
    }
  }

  /// Get installed apps filtered by a search query
  /// 
  /// Returns apps whose name contains the [query] (case-insensitive).
  Future<List<AppInfo>> searchApps(
    String query, {
    bool includeSystemApps = false,
  }) async {
    try {
      return await NativeService.searchApps(query, includeSystemApps: includeSystemApps);
    } catch (e) {
      throw Exception('Failed to search apps: $e');
    }
  }

  /// Get a specific app by package name
  /// 
  /// Returns null if the app is not found.
  Future<AppInfo?> getAppByPackageName(String packageName) async {
    try {
      return await NativeService.getAppByPackageName(packageName);
    } catch (e) {
      return null;
    }
  }
}
