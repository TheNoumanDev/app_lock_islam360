import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/features/quran/screens/quran_screen.dart';
import 'package:app_lock_islam360/core/constants/app_strings.dart';

void main() {
  group('QuranScreen', () {
    testWidgets('renders coming soon placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QuranScreen()),
      );
      await tester.pump();

      expect(find.text(AppStrings.navQuran), findsOneWidget);
      expect(find.text(AppStrings.comingSoon), findsOneWidget);
      expect(find.text(AppStrings.comingSoonDesc), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });
  });
}
