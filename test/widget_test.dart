// Widget tests for the CIVIC Campus app.
//
// These tests verify that the splash screen transitions into the login flow
// after the configured delay.

import 'package:civic_campus/app.dart';
import 'package:civic_campus/screens/login_screen.dart';
import 'package:civic_campus/screens/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashScreen navigates to LoginScreen after delay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CivicCampusApp());

    // Splash screen should appear first.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    // Advance fake time slightly past the configured splash delay.
    await tester.pump(
      SplashScreen.duration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    // Login screen should now be visible.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });
}
