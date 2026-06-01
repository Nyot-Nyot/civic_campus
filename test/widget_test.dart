// Widget tests for the CIVIC Campus app.
//
// These tests verify that the splash screen transitions into the login flow
// after the configured delay.

import 'package:civic_campus/app.dart';
import 'package:civic_campus/screens/login_screen.dart';
import 'package:civic_campus/screens/splash_screen.dart';
import 'package:civic_campus/screens/student_home_screen.dart';
import 'package:flutter/material.dart';
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

  testWidgets('Login with valid input navigates to StudentHomeScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CivicCampusApp());
    await tester.pump(
      SplashScreen.duration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    final emailField = find.byKey(const Key('login_email'));
    final passwordField = find.byKey(const Key('login_password'));
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');

    await tester.enterText(emailField, 'mahasiswa@campus.id');
    await tester.enterText(passwordField, 'secure123');
    await tester.pumpAndSettle();

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.byType(StudentHomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Login berhasil — menuju Student Home.'), findsOneWidget);
  });

  testWidgets('Login with invalid input does not navigate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CivicCampusApp());
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
    await tester.pumpWidget(const CivicCampusApp());
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
}
