import 'package:civic_campus/app.dart';
import 'package:civic_campus/screens/admin_home_screen.dart';
import 'package:civic_campus/screens/login_screen.dart';
import 'package:civic_campus/screens/new_report_screen.dart';
import 'package:civic_campus/screens/splash_screen.dart';
import 'package:civic_campus/screens/staff_home_screen.dart';
import 'package:civic_campus/screens/student_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashScreen navigates to LoginScreen after delay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CivicCampusApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    await tester.pump(
      SplashScreen.duration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

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

  testWidgets('Role button "Student" navigates to StudentHomeScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CivicCampusApp());
    await tester.pump(
      SplashScreen.duration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Student'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Student'));
    await tester.pumpAndSettle();

    expect(find.byType(StudentHomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('Role button "Staff" navigates to StaffHomeScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CivicCampusApp());
    await tester.pump(
      SplashScreen.duration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Staff'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Staff'));
    await tester.pumpAndSettle();

    expect(find.byType(StaffHomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('Role button "Facility Admin" navigates to AdminHomeScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CivicCampusApp());
    await tester.pump(
      SplashScreen.duration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Facility Admin'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Facility Admin'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminHomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('Role button "Super Admin" navigates to SuperAdminHomeScreen', (
    tester,
  ) async {
    await tester.pumpWidget(const CivicCampusApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Super Admin'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Super Admin'));
    await tester.pumpAndSettle();

    expect(find.text('Pengguna Terdaftar'), findsOneWidget);
  });

  testWidgets('StudentHomeScreen CTA opens NewReportScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: StudentHomeScreen()),
    );

    expect(find.byType(StudentHomeScreen), findsOneWidget);
    expect(find.byType(NewReportScreen), findsNothing);

    final cta = find.text('Laporkan Masalah');
    expect(cta, findsOneWidget);

    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.byType(NewReportScreen), findsOneWidget);
    expect(find.text('Pilih Lokasi'), findsOneWidget);
  });

  testWidgets('Bottom nav plus button opens NewReportScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: StudentHomeScreen()),
    );

    expect(find.byType(NewReportScreen), findsNothing);

    // Tap the "+" bottom nav item (index 1).
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
      const MaterialApp(home: StudentHomeScreen()),
    );

    await tester.tap(find.text('Laporkan Masalah'));
    await tester.pumpAndSettle();

    expect(find.byType(NewReportScreen), findsOneWidget);

    // Tap the back arrow in the NewReportScreen header.
    final backButton = find.byIcon(Icons.arrow_back);
    expect(backButton, findsOneWidget);

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(StudentHomeScreen), findsOneWidget);
    expect(find.byType(NewReportScreen), findsNothing);
  });
}
