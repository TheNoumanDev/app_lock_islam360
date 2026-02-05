import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/core/router/app_router.dart';

void main() {
  group('RoutePaths', () {
    test('splash path is root', () {
      expect(RoutePaths.splash, '/');
    });

    test('all route paths start with /', () {
      expect(RoutePaths.home, startsWith('/'));
      expect(RoutePaths.apps, startsWith('/'));
      expect(RoutePaths.alarms, startsWith('/'));
      expect(RoutePaths.prayer, startsWith('/'));
      expect(RoutePaths.quran, startsWith('/'));
      expect(RoutePaths.onboarding, startsWith('/'));
      expect(RoutePaths.profile, startsWith('/'));
    });

    test('route paths are unique', () {
      final paths = [
        RoutePaths.splash,
        RoutePaths.home,
        RoutePaths.apps,
        RoutePaths.alarms,
        RoutePaths.prayer,
        RoutePaths.quran,
        RoutePaths.onboarding,
        RoutePaths.profile,
      ];
      expect(paths.toSet().length, paths.length);
    });
  });
}
