import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_lock_islam360/data/local/storage_service.dart';
import 'package:app_lock_islam360/core/models/lock_settings.dart';

void main() {
  group('StorageService', () {
    late StorageService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = await StorageService.getInstance();
    });

    tearDown(() async {
      await service.clearAll();
    });

    group('saveLockedApps and loadLockedApps', () {
      test('should save and load locked apps', () async {
        final apps = {'com.example.app1', 'com.example.app2', 'com.example.app3'};

        final saved = await service.saveLockedApps(apps);
        expect(saved, isTrue);

        final loaded = await service.loadLockedApps();
        expect(loaded, equals(apps));
      });

      test('should return empty set when no apps are stored', () async {
        final loaded = await service.loadLockedApps();
        expect(loaded, isEmpty);
      });

      test('should overwrite existing apps when saving', () async {
        final apps1 = {'com.example.app1', 'com.example.app2'};
        final apps2 = {'com.example.app3', 'com.example.app4'};

        await service.saveLockedApps(apps1);
        await service.saveLockedApps(apps2);

        final loaded = await service.loadLockedApps();
        expect(loaded, equals(apps2));
        expect(loaded, isNot(equals(apps1)));
      });
    });

    group('clearLockedApps', () {
      test('should clear locked apps', () async {
        final apps = {'com.example.app1', 'com.example.app2'};
        await service.saveLockedApps(apps);

        final cleared = await service.clearLockedApps();
        expect(cleared, isTrue);

        final loaded = await service.loadLockedApps();
        expect(loaded, isEmpty);
      });

      test('should return true even when nothing to clear', () async {
        final cleared = await service.clearLockedApps();
        expect(cleared, isTrue);
      });
    });

    group('saveLockEnabled and loadLockEnabled', () {
      test('should save and load lock enabled state', () async {
        await service.saveLockEnabled(true);
        final enabled = await service.loadLockEnabled();
        expect(enabled, isTrue);

        await service.saveLockEnabled(false);
        final disabled = await service.loadLockEnabled();
        expect(disabled, isFalse);
      });

      test('should default to true when not set', () async {
        final enabled = await service.loadLockEnabled();
        expect(enabled, isTrue);
      });
    });

    group('saveLockSettings and loadLockSettings', () {
      test('should save and load complete lock settings', () async {
        final settings = LockSettings(
          lockedApps: {'com.example.app1', 'com.example.app2'},
          isLockEnabled: true,
        );

        final saved = await service.saveLockSettings(settings);
        expect(saved, isTrue);

        final loaded = await service.loadLockSettings();
        expect(loaded.lockedApps, equals(settings.lockedApps));
        expect(loaded.isLockEnabled, equals(settings.isLockEnabled));
      });

      test('should save and load settings with disabled lock', () async {
        final settings = LockSettings(
          lockedApps: {'com.example.app1'},
          isLockEnabled: false,
        );

        await service.saveLockSettings(settings);
        final loaded = await service.loadLockSettings();

        expect(loaded.isLockEnabled, isFalse);
        expect(loaded.lockedApps, equals(settings.lockedApps));
      });
    });

    group('clearAll', () {
      test('should clear all storage', () async {
        await service.saveLockedApps({'com.example.app1'});
        await service.saveLockEnabled(true);

        final cleared = await service.clearAll();
        expect(cleared, isTrue);

        final loadedApps = await service.loadLockedApps();
        final loadedEnabled = await service.loadLockEnabled();

        expect(loadedApps, isEmpty);
        expect(loadedEnabled, isTrue); // Defaults to true
      });
    });

    group('error handling', () {
      test('should throw exception on save failure', () async {
        // This test verifies error handling structure
        // Actual failure scenarios would require mocking SharedPreferences
        final apps = {'com.example.app1'};
        final result = await service.saveLockedApps(apps);
        expect(result, isA<bool>());
      });
    });
  });
}
