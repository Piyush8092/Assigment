// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:streak_tracker/main.dart';

void main() {
  testWidgets('Streak Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StreakTrackerApp());

    // Verify that the app loads with the streak tracker title
    expect(find.text('Streak Tracker'), findsOneWidget);

    // Verify that the check-in button is present
    expect(find.text('Check In Today'), findsOneWidget);
  });
}
