import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/features/profile/screens/profile_screen.dart';
import 'package:app_lock_islam360/core/constants/app_strings.dart';

void main() {
  group('ProfileScreen', () {
    testWidgets('renders profile header and settings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfileScreen()),
      );
      await tester.pump();

      expect(find.text(AppStrings.profile), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text(AppStrings.profileAchievements), findsOneWidget);
      expect(find.text(AppStrings.profileNotifications), findsOneWidget);
      expect(find.text(AppStrings.profileAppearance), findsOneWidget);
      expect(find.text(AppStrings.profileAbout), findsOneWidget);
      expect(find.text(AppStrings.profilePrivacy), findsOneWidget);
      expect(find.text(AppStrings.profileTerms), findsOneWidget);
    });

    testWidgets('renders achievement badges', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfileScreen()),
      );
      await tester.pump();

      expect(find.text('0 Days'), findsOneWidget);
      expect(find.text('0 Ayat'), findsOneWidget);
      expect(find.text('0 Locks'), findsOneWidget);
    });
  });
}
