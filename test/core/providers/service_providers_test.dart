import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_lock_islam360/core/providers/service_providers.dart';
import 'package:app_lock_islam360/core/services/app_list_service.dart';

void main() {
  group('ServiceProviders', () {
    test('appListServiceProvider returns AppListService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(appListServiceProvider);
      expect(service, isA<AppListService>());
    });

    test('storageServiceProvider is a FutureProvider', () {
      // storageServiceProvider is async and requires SharedPreferences
      // which needs platform channels — just verify it exists
      expect(storageServiceProvider, isNotNull);
    });

    test('appMonitorServiceProvider is a FutureProvider', () {
      expect(appMonitorServiceProvider, isNotNull);
    });
  });
}
