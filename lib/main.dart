import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'data/local/storage_service.dart';
import 'core/services/native_service.dart';

/// Global navigator key for programmatic navigation from native calls
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: NafsGuardApp()));
}

class NafsGuardApp extends ConsumerStatefulWidget {
  const NafsGuardApp({super.key});

  @override
  ConsumerState<NafsGuardApp> createState() => _NafsGuardAppState();
}

class _NafsGuardAppState extends ConsumerState<NafsGuardApp> {
  static const _channel = MethodChannel('com.example.app_lock_islam360/native');

  @override
  void initState() {
    super.initState();
    _setupMethodChannelHandler();
    _syncLockedAppsOnStart();
  }

  /// Set up listener for native → Flutter method calls
  void _setupMethodChannelHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'showLockScreen') {
        final args = call.arguments as Map<dynamic, dynamic>;
        final packageName = args['packageName'] as String? ?? '';
        final appName = args['appName'] as String? ?? 'App';

        debugPrint('Received showLockScreen call: $appName ($packageName)');

        // Navigate to lock screen using GoRouter
        final router = ref.read(routerProvider);
        router.push(
          RoutePaths.lockFeeling,
          extra: {
            'packageName': packageName,
            'appName': appName,
          },
        );
      }
    });
  }

  /// Sync locked apps to native layer on app start
  /// This enables auto-lock when apps are selected
  Future<void> _syncLockedAppsOnStart() async {
    try {
      final storage = await StorageService.getInstance();
      final lockedApps = await storage.loadLockedApps();

      if (lockedApps.isNotEmpty) {
        // Check if accessibility service is enabled
        final isAccessibilityEnabled =
            await NativeService.isAccessibilityServiceEnabled();

        if (isAccessibilityEnabled) {
          // Sync locked apps to native layer (convert Set to List)
          await NativeService.updateLockedAppsForAccessibility(
              lockedApps.toList());
          // Enable lock automatically since apps are selected
          await NativeService.updateLockEnabledForAccessibility(true);
          debugPrint('Auto-enabled app lock with ${lockedApps.length} apps');
        }
      }
    } catch (e) {
      debugPrint('Error syncing locked apps on start: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
