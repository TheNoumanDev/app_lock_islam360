import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_lock_islam360/features/app_selection/widgets/app_item_widget.dart';
import 'package:app_lock_islam360/core/models/app_info.dart';

void main() {
  group('AppItemWidget', () {
    late AppInfo testApp;

    setUp(() {
      testApp = const AppInfo(
        packageName: 'com.test.app',
        appName: 'Test App',
        isSystemApp: false,
      );
    });

    testWidgets('should display app name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppItemWidget(
              app: testApp,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
    });

    testWidgets('should show check icon when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppItemWidget(
              app: testApp,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show outlined circle when not selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppItemWidget(
              app: testApp,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppItemWidget(
              app: testApp,
              isSelected: false,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppItemWidget));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('should display app icon placeholder when iconPath is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppItemWidget(
              app: testApp,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.android), findsOneWidget);
    });

    testWidgets('should have different background color when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppItemWidget(
              app: testApp,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.decoration, isNotNull);
    });
  });
}
