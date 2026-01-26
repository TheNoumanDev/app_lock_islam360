// Basic app smoke test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/main.dart';
import 'package:app_lock_islam360/core/constants/app_strings.dart';

void main() {
  testWidgets('App launches and shows app selection screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify that the app selection screen is displayed
    expect(find.text(AppStrings.selectApps), findsOneWidget);
  });
}
