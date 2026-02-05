import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/features/app_lock/screens/feeling_input_screen.dart';
import 'package:app_lock_islam360/features/app_lock/data/islamic_content.dart';

void main() {
  group('FeelingInputScreen', () {
    testWidgets('renders lock icon and app name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeelingInputScreen(
            appName: 'Test App',
            packageName: 'com.test.app',
          ),
        ),
      );

      // Check for lock icon
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);

      // Check for app name
      expect(find.text('Test App'), findsOneWidget);
    });

    testWidgets('renders feeling question', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeelingInputScreen(
            appName: 'Test App',
            packageName: 'com.test.app',
          ),
        ),
      );

      expect(find.text('How are you feeling right now?'), findsOneWidget);
    });

    testWidgets('renders text input with placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeelingInputScreen(
            appName: 'Test App',
            packageName: 'com.test.app',
          ),
        ),
      );

      expect(
        find.widgetWithText(TextField, 'Why am I reaching for this app?'),
        findsOneWidget,
      );
    });

    testWidgets('continue button is disabled when input is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeelingInputScreen(
            appName: 'Test App',
            packageName: 'com.test.app',
          ),
        ),
      );

      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('continue button is enabled when input has text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeelingInputScreen(
            appName: 'Test App',
            packageName: 'com.test.app',
          ),
        ),
      );

      // Enter text in the input field
      await tester.enterText(find.byType(TextField), 'I feel stressed');
      await tester.pump();

      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('renders divider text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeelingInputScreen(
            appName: 'Test App',
            packageName: 'com.test.app',
          ),
        ),
      );

      expect(find.text('or choose from below'), findsOneWidget);
    });

    testWidgets('renders all predefined feeling chips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeelingInputScreen(
            appName: 'Test App',
            packageName: 'com.test.app',
          ),
        ),
      );

      // Check that all predefined feelings are displayed
      for (final feeling in predefinedFeelings) {
        expect(find.text(feeling), findsOneWidget);
      }
    });
  });
}
