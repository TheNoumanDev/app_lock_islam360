import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/features/prayer_times/widgets/prayer_tile.dart';

void main() {
  group('PrayerTile', () {
    testWidgets('renders completed state with checkmark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrayerTile(
              name: 'Fajr',
              time: '05:30',
              state: PrayerTileState.completed,
            ),
          ),
        ),
      );

      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('05:30'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('renders current state without checkmark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrayerTile(
              name: 'Asr',
              time: '15:30',
              state: PrayerTileState.current,
            ),
          ),
        ),
      );

      expect(find.text('Asr'), findsOneWidget);
      expect(find.text('15:30'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('renders upcoming state without checkmark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrayerTile(
              name: 'Maghrib',
              time: '18:15',
              state: PrayerTileState.upcoming,
            ),
          ),
        ),
      );

      expect(find.text('Maghrib'), findsOneWidget);
      expect(find.text('18:15'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}
