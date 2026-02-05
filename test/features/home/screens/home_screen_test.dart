import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/features/home/screens/home_screen.dart';
import 'package:app_lock_islam360/features/home/widgets/prayer_card.dart';
import 'package:app_lock_islam360/features/home/widgets/noor_streak_card.dart';
import 'package:app_lock_islam360/features/home/widgets/quick_actions_row.dart';
import 'package:app_lock_islam360/features/home/widgets/continue_reading_card.dart';
import 'package:app_lock_islam360/core/constants/app_strings.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders greeting and all sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      expect(find.text(AppStrings.homeGreeting), findsOneWidget);
      expect(find.byType(PrayerCard), findsOneWidget);
      expect(find.byType(ContinueReadingCard), findsOneWidget);
      expect(find.byType(NoorStreakCard), findsOneWidget);
      expect(find.byType(QuickActionsRow), findsOneWidget);
      expect(find.text(AppStrings.homeNoorStreak), findsOneWidget);
      expect(find.text(AppStrings.homeQuickActions), findsOneWidget);
    });

    testWidgets('renders profile avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}
