import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:app_lock_islam360/features/app_lock/screens/ayat_display_screen.dart';
import 'package:app_lock_islam360/features/app_lock/data/islamic_content.dart';
import 'package:app_lock_islam360/core/router/app_router.dart';

void main() {
  group('AyatDisplayScreen', () {
    late bool onCompleteCalled;

    Widget buildTestWidget({VoidCallback? onSkip}) {
      // Create a test router that includes the AyatDisplayScreen route
      final testRouter = GoRouter(
        initialLocation: RoutePaths.lockAyat,
        routes: [
          GoRoute(
            path: RoutePaths.home,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
          ),
          GoRoute(
            path: RoutePaths.lockAyat,
            builder: (context, state) => AyatDisplayScreen(
              feeling: 'Stressed',
              appName: 'Test App',
              packageName: 'com.test.app',
              onComplete: () => onCompleteCalled = true,
              onSkip: onSkip ?? () {},
            ),
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: testRouter,
      );
    }

    Future<void> pumpAndFinish(WidgetTester tester) async {
      // Wait for countdown to complete and all animations to finish
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    }

    setUp(() {
      onCompleteCalled = false;
    });

    testWidgets('renders Quranic verse header', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('QURANIC VERSE'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);

      await pumpAndFinish(tester);
    });

    testWidgets('renders Arabic text for feeling', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final content = getContentForFeeling('Stressed');
      expect(find.text(content.arabic), findsOneWidget);

      await pumpAndFinish(tester);
    });

    testWidgets('renders translation and reference', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final content = getContentForFeeling('Stressed');
      expect(find.textContaining(content.reference), findsOneWidget);

      await pumpAndFinish(tester);
    });

    testWidgets('shows countdown initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('3'), findsOneWidget);

      await pumpAndFinish(tester);
    });

    testWidgets('shows reflection message initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Take a moment to reflect...'), findsOneWidget);

      await pumpAndFinish(tester);
    });

    testWidgets('done button is disabled initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final doneButton = find.widgetWithText(ElevatedButton, 'Done');
      expect(doneButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(doneButton);
      expect(button.onPressed, isNull);

      await pumpAndFinish(tester);
    });

    testWidgets('shows shake hint', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.text('Shake device to skip in emergencies'),
        findsOneWidget,
      );

      await pumpAndFinish(tester);
    });

    testWidgets('countdown completes after 3 seconds', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Wait for countdown to complete
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Reflection complete'), findsOneWidget);

      // Done button should be enabled now
      final doneButton = find.widgetWithText(ElevatedButton, 'Done');
      final button = tester.widget<ElevatedButton>(doneButton);
      expect(button.onPressed, isNotNull);

      await tester.pumpAndSettle();
    });

    testWidgets('onComplete is called when done button is pressed', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Wait for countdown to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      // Tap done button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Done'));
      await tester.pump();

      expect(onCompleteCalled, true);

      await tester.pumpAndSettle();
    });
  });
}
