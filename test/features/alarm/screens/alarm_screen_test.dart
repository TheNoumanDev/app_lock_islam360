import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/features/alarm/screens/alarm_screen.dart';
import 'package:app_lock_islam360/core/constants/app_strings.dart';

void main() {
  group('AlarmScreen', () {
    testWidgets('renders coming soon placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AlarmScreen()),
      );
      await tester.pump();

      expect(find.text(AppStrings.navAlarms), findsOneWidget);
      expect(find.text(AppStrings.comingSoon), findsOneWidget);
      expect(find.text(AppStrings.comingSoonDesc), findsOneWidget);
      expect(find.byIcon(Icons.alarm), findsOneWidget);
    });
  });
}
