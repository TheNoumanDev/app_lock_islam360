import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/features/prayer_times/screens/prayer_times_screen.dart';
import 'package:app_lock_islam360/features/prayer_times/widgets/prayer_tile.dart';
import 'package:app_lock_islam360/core/constants/app_strings.dart';

void main() {
  group('PrayerTimesScreen', () {
    testWidgets('renders prayer times with countdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrayerTimesScreen()),
      );
      await tester.pump();

      // Check for location and madhab
      expect(find.text('Karachi'), findsOneWidget);
      expect(find.text(AppStrings.prayerHanafi), findsOneWidget);

      // Check for UPCOMING label
      expect(find.text(AppStrings.prayerUpcoming), findsOneWidget);

      // Check all 5 prayer tiles are rendered
      expect(find.byType(PrayerTile), findsNWidgets(5));
    });

    testWidgets('renders Islamic and Gregorian date', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrayerTimesScreen()),
      );
      await tester.pump();

      // Check for AH (Hijri year indicator)
      expect(find.textContaining('AH'), findsOneWidget);

      // Check for current year in Gregorian date
      final currentYear = DateTime.now().year.toString();
      expect(find.textContaining(currentYear), findsOneWidget);
    });

    testWidgets('renders countdown timer format', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrayerTimesScreen()),
      );
      await tester.pump();

      // Check for countdown format with colons (HH:MM:SS)
      expect(find.textContaining(':'), findsWidgets);
    });

    testWidgets('renders until next prayer text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrayerTimesScreen()),
      );
      await tester.pump();

      // Check for "until" text
      expect(find.textContaining(AppStrings.prayerUntil), findsOneWidget);
    });
  });
}
