import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_lock_islam360/features/onboarding/widgets/permissions_slide.dart';
import 'package:app_lock_islam360/core/constants/app_strings.dart';

void main() {
  group('PermissionsSlide', () {
    testWidgets('renders security icon', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PermissionsSlide()),
        ),
      );

      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PermissionsSlide()),
        ),
      );

      expect(find.text(AppStrings.onboardingTitlePermissions), findsOneWidget);
    });

    testWidgets('renders description', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PermissionsSlide()),
        ),
      );

      expect(find.text(AppStrings.onboardingDescPermissions), findsOneWidget);
    });

    testWidgets('renders three permission cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PermissionsSlide()),
        ),
      );

      // Check for permission titles
      expect(find.text(AppStrings.permissionAccessibility), findsOneWidget);
      expect(find.text(AppStrings.permissionOverlay), findsOneWidget);
      expect(find.text(AppStrings.permissionNotification), findsOneWidget);
    });

    testWidgets('renders permission icons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PermissionsSlide()),
        ),
      );

      expect(find.byIcon(Icons.accessibility_new), findsOneWidget);
      expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('shows required badge for accessibility permission', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PermissionsSlide()),
        ),
      );

      // Should show 'Required' badge for accessibility and overlay
      expect(find.text(AppStrings.permissionRequired), findsNWidgets(2));
    });

    testWidgets('shows optional badge for notification permission', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PermissionsSlide()),
        ),
      );

      // Should show 'Optional' badge for notification
      expect(find.text(AppStrings.permissionOptional), findsOneWidget);
    });
  });
}
