import 'package:civic_campus/app.dart';
import 'package:civic_campus/screens/auth/login_screen.dart';
import 'package:civic_campus/screens/student/new_report_screen.dart';
import 'package:civic_campus/screens/auth/splash_screen.dart';
import 'package:civic_campus/screens/student/student_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helper.dart';

void main() {
  setUpAll(() async {
    await initTestEnv();
  });

  testWidgets('SplashScreen navigates to LoginScreen after delay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(child: const CivicCampusApp()),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    await tester.pump(
      SplashScreen.duration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('Login with invalid input does not navigate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(child: const CivicCampusApp()),
    );
    await tester.pump(
      SplashScreen.duration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    final emailField = find.byKey(const Key('login_email'));
    final passwordField = find.byKey(const Key('login_password'));
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');

    await tester.enterText(emailField, 'invalid-email');
    await tester.enterText(passwordField, '123');
    await tester.pumpAndSettle();

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.byType(StudentHomeScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(find.text('Minimal 6 karakter'), findsOneWidget);
  });

  testWidgets('Login with empty input does not navigate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(child: const CivicCampusApp()),
    );
    await tester.pump(
      SplashScreen.duration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    final emailField = find.byKey(const Key('login_email'));
    final passwordField = find.byKey(const Key('login_password'));
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');

    await tester.enterText(emailField, '');
    await tester.enterText(passwordField, '');
    await tester.pumpAndSettle();

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.byType(StudentHomeScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
  });

  testWidgets('StudentHomeScreen CTA opens NewReportScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const MaterialApp(home: StudentHomeScreen()),
      ),
    );

    expect(find.byType(StudentHomeScreen), findsOneWidget);
    expect(find.byType(NewReportScreen), findsNothing);

    final cta = find.text('Laporkan Masalah');
    expect(cta, findsOneWidget);

    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.byType(NewReportScreen), findsOneWidget);
  });

  testWidgets('Bottom nav plus button opens NewReportScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const MaterialApp(home: StudentHomeScreen()),
      ),
    );

    expect(find.byType(NewReportScreen), findsNothing);

    final plusButton = find.byIcon(Icons.add_circle_outline);
    expect(plusButton, findsOneWidget);

    await tester.tap(plusButton);
    await tester.pumpAndSettle();

    expect(find.byType(NewReportScreen), findsOneWidget);
  });

  testWidgets('Back from NewReportScreen returns to StudentHomeScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const MaterialApp(home: StudentHomeScreen()),
      ),
    );

    await tester.tap(find.text('Laporkan Masalah'));
    await tester.pumpAndSettle();

    expect(find.byType(NewReportScreen), findsOneWidget);

    final backButton = find.byIcon(Icons.arrow_back);
    expect(backButton, findsOneWidget);

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(StudentHomeScreen), findsOneWidget);
    expect(find.byType(NewReportScreen), findsNothing);
  });
}
