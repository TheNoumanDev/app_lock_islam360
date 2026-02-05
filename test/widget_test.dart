// Basic app smoke test
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_lock_islam360/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NafsGuardApp()));
    await tester.pump();

    // App should launch without crashing
    expect(find.byType(NafsGuardApp), findsOneWidget);
  });
}
