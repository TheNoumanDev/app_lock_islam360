import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_lock_islam360/features/onboarding/screens/onboarding_screen.dart';
import 'package:app_lock_islam360/core/constants/app_strings.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders first slide with title and skip', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);
      expect(find.text(AppStrings.skip), findsOneWidget);
      expect(find.text(AppStrings.next), findsOneWidget);
    });

    testWidgets('renders dot indicators for 6 slides', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pump();

      // 6 dot indicators (AnimatedContainer) - includes permissions slide
      expect(find.byType(AnimatedContainer), findsNWidgets(6));
    });

    testWidgets('tapping next navigates to second slide', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pump();

      // Tap next
      await tester.tap(find.text(AppStrings.next));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.onboardingTitle2), findsOneWidget);
    });
  });
}
