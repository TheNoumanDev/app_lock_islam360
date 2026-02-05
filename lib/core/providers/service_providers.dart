import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/storage_service.dart';
import '../services/app_list_service.dart';
import '../services/app_monitor_service.dart';

/// Provider for StorageService singleton
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return StorageService.getInstance();
});

/// Provider for AppListService
final appListServiceProvider = Provider<AppListService>((ref) {
  return AppListService();
});

/// Provider for AppMonitorService singleton
final appMonitorServiceProvider = FutureProvider<AppMonitorService>((ref) async {
  return AppMonitorService.getInstance();
});
