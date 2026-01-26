import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/lock_settings.dart';

/// Service for managing local storage using SharedPreferences
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  /// Get singleton instance
  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Save locked apps list
  /// 
  /// Saves the set of package names to SharedPreferences
  Future<bool> saveLockedApps(Set<String> packageNames) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setStringList(
        AppConstants.storageKeyLockedApps,
        packageNames.toList(),
      );
    } catch (e) {
      throw Exception('Failed to save locked apps: $e');
    }
  }

  /// Load locked apps list
  /// 
  /// Returns the set of package names from SharedPreferences
  /// Returns empty set if nothing is stored
  Future<Set<String>> loadLockedApps() async {
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(AppConstants.storageKeyLockedApps);
      return list != null ? Set<String>.from(list) : <String>{};
    } catch (e) {
      throw Exception('Failed to load locked apps: $e');
    }
  }

  /// Clear locked apps list
  /// 
  /// Removes the locked apps from storage
  Future<bool> clearLockedApps() async {
    try {
      final prefs = await _getPrefs();
      return await prefs.remove(AppConstants.storageKeyLockedApps);
    } catch (e) {
      throw Exception('Failed to clear locked apps: $e');
    }
  }

  /// Save lock enabled state
  /// 
  /// Saves whether the app lock is enabled or disabled
  Future<bool> saveLockEnabled(bool enabled) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setBool(
        AppConstants.storageKeyLockEnabled,
        enabled,
      );
    } catch (e) {
      throw Exception('Failed to save lock enabled state: $e');
    }
  }

  /// Load lock enabled state
  /// 
  /// Returns true if lock is enabled, false otherwise
  /// Defaults to true if not set
  Future<bool> loadLockEnabled() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(AppConstants.storageKeyLockEnabled) ?? true;
    } catch (e) {
      throw Exception('Failed to load lock enabled state: $e');
    }
  }

  /// Save complete lock settings
  /// 
  /// Saves both locked apps and lock enabled state
  Future<bool> saveLockSettings(LockSettings settings) async {
    try {
      final appsSaved = await saveLockedApps(settings.lockedApps);
      final enabledSaved = await saveLockEnabled(settings.isLockEnabled);
      return appsSaved && enabledSaved;
    } catch (e) {
      throw Exception('Failed to save lock settings: $e');
    }
  }

  /// Load complete lock settings
  /// 
  /// Loads both locked apps and lock enabled state
  Future<LockSettings> loadLockSettings() async {
    try {
      final lockedApps = await loadLockedApps();
      final isLockEnabled = await loadLockEnabled();
      return LockSettings(
        lockedApps: lockedApps,
        isLockEnabled: isLockEnabled,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to load lock settings: $e');
    }
  }

  /// Clear all storage
  /// 
  /// Removes all stored data
  Future<bool> clearAll() async {
    try {
      final prefs = await _getPrefs();
      return await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear all storage: $e');
    }
  }

  /// Get SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
