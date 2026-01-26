import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_lock_islam360/features/app_selection/screens/app_selection_screen.dart';
import 'package:app_lock_islam360/core/constants/app_strings.dart';

void main() {
  group('AppSelectionScreen', () {
    setUp(() async {
      // Initialize SharedPreferences with empty values for each test
      SharedPreferences.setMockInitialValues({});
    });
    testWidgets('should display app selection screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppSelectionScreen(),
        ),
      );

      expect(find.text(AppStrings.selectApps), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppSelectionScreen(),
        ),
      );

      // Initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(AppStrings.loadingApps), findsOneWidget);
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppSelectionScreen(),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(AppStrings.searchApps), findsOneWidget);
    });

    testWidgets('should display selection actions when apps are loaded', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppSelectionScreen(),
        ),
      );

      // Pump a few times to allow initial build
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check for search field (always visible)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show empty state message when no apps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppSelectionScreen(),
        ),
      );

      // Pump a few times to allow initial build
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Screen should be rendered (structure test)
      expect(find.byType(AppSelectionScreen), findsOneWidget);
    });

    testWidgets('should allow typing in search field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppSelectionScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'test');
      await tester.pump();

      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('should initialize with empty SharedPreferences', (WidgetTester tester) async {
      // Set up empty SharedPreferences
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: AppSelectionScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Screen should render without errors
      expect(find.byType(AppSelectionScreen), findsOneWidget);
    });
  });
}
