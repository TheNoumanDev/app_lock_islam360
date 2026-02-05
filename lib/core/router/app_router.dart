import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../services/native_service.dart';
import 'app_shell.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/app_selection/screens/app_selection_screen.dart';
import '../../features/alarm/screens/alarm_screen.dart';
import '../../features/prayer_times/screens/prayer_times_screen.dart';
import '../../features/quran/screens/quran_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/app_lock/screens/feeling_input_screen.dart';
import '../../features/app_lock/screens/ayat_display_screen.dart';

/// Route paths
class RoutePaths {
  RoutePaths._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String apps = '/apps';
  static const String alarms = '/alarms';
  static const String prayer = '/prayer';
  static const String quran = '/quran';
  static const String profile = '/profile';
  // Lock screen routes
  static const String lockFeeling = '/lock/feeling';
  static const String lockAyat = '/lock/ayat';
}

/// Navigation shell key for preserving state
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    routes: [
      // Splash / redirect route
      GoRoute(
        path: RoutePaths.splash,
        redirect: (context, state) async {
          final onboardingState = ref.read(onboardingCompleteProvider);
          final isComplete = onboardingState.valueOrNull ?? false;
          return isComplete ? RoutePaths.home : RoutePaths.onboarding;
        },
      ),
      // Onboarding (full screen, no bottom nav)
      GoRoute(
        path: RoutePaths.onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Profile (full screen, no bottom nav)
      GoRoute(
        path: RoutePaths.profile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      // Lock screen - Feeling input (full screen, no bottom nav)
      GoRoute(
        path: RoutePaths.lockFeeling,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return FeelingInputScreen(
            appName: extra['appName'] as String? ?? 'App',
            packageName: extra['packageName'] as String? ?? '',
          );
        },
      ),
      // Lock screen - Ayat display (full screen, no bottom nav)
      GoRoute(
        path: RoutePaths.lockAyat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final feeling = extra['feeling'] as String? ?? '';
          final appName = extra['appName'] as String? ?? 'App';
          final packageName = extra['packageName'] as String? ?? '';
          return AyatDisplayScreen(
            feeling: feeling,
            appName: appName,
            packageName: packageName,
            onComplete: () async {
              // Unlock and allow access to the app
              await NativeService.unlockAndContinue(packageName);
              // Minimize Flutter app to return to the unlocked app
              await NativeService.minimizeApp();
            },
            onSkip: () async {
              // Emergency skip - unlock and minimize
              await NativeService.unlockAndContinue(packageName);
              await NativeService.minimizeApp();
            },
          );
        },
      ),
      // Shell route with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.apps,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AppSelectionScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.alarms,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AlarmScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.prayer,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerTimesScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.quran,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuranScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
