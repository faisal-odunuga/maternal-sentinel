// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:maternal_sentinel/main.dart';

void main() {
  testWidgets('Splash navigates to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const MaternalSentinelApp());

    expect(find.text('Maternal Sentinel'), findsOneWidget);
    expect(find.text('Register as a Health Worker.'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Register as a Health Worker.'), findsOneWidget);
  });
}
