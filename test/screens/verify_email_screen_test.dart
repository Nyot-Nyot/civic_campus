import 'package:civic_campus/api/user_api.dart';
import 'package:civic_campus/core/auth_service.dart';
import 'package:civic_campus/data/providers/auth_provider.dart';
import 'package:civic_campus/screens/auth/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../test_helper.dart';

class SuccessVerifyAuth extends AuthService {
  SuccessVerifyAuth() : super(client: MockApiClient());

  @override
  bool get isAuthenticated => false;
  @override
  String? get userId => null;
  @override
  AuthSession? get session => null;

  @override
  Future<String?> verifyEmail(String email, String otp) async => null;
  @override
  Future<String?> resendVerificationEmail(String email) async => null;
}

class FailingResendAuth extends AuthService {
  FailingResendAuth() : super(client: MockApiClient());

  @override
  bool get isAuthenticated => false;
  @override
  String? get userId => null;
  @override
  AuthSession? get session => null;

  @override
  Future<String?> verifyEmail(String email, String otp) async => null;
  @override
  Future<String?> resendVerificationEmail(String email) async =>
      'Simulasi error kirim ulang';
}

class FailingVerifyAuth extends AuthService {
  FailingVerifyAuth() : super(client: MockApiClient());

  @override
  bool get isAuthenticated => false;
  @override
  String? get userId => null;
  @override
  AuthSession? get session => null;

  @override
  Future<String?> verifyEmail(String email, String otp) async =>
      'Kode verifikasi salah';
  @override
  Future<String?> resendVerificationEmail(String email) async => null;
}

Widget buildVerifyScreen({required String email, AuthService? authOverride}) {
  final apiClient = MockApiClient();
  final userApi = UserApi(apiClient);
  final auth = authOverride ?? SuccessVerifyAuth();

  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService: auth, userApi: userApi),
        ),
      ],
      child: VerifyEmailScreen(email: email),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initTestEnv();
  });

  group('VerifyEmailScreen', () {
    testWidgets('shows email in the card', (tester) async {
      await tester.pumpWidget(buildVerifyScreen(email: 'mahasiswa@campus.id'));
      await tester.pumpAndSettle();

      expect(find.text('mahasiswa@campus.id'), findsOneWidget);
      expect(find.text('Verifikasi Email'), findsOneWidget);
    });

    testWidgets('shows 6 OTP text fields', (tester) async {
      await tester.pumpWidget(buildVerifyScreen(email: 'test@campus.id'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('verify button is disabled when OTP is incomplete', (
      tester,
    ) async {
      await tester.pumpWidget(buildVerifyScreen(email: 'test@campus.id'));
      await tester.pumpAndSettle();

      final verifyButton = find.widgetWithText(ElevatedButton, 'Verifikasi');
      expect(verifyButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(verifyButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('resend button shows success snackbar', (tester) async {
      await tester.pumpWidget(buildVerifyScreen(email: 'test@campus.id'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kirim ulang kode'));
      await tester.pumpAndSettle();

      expect(find.text('Kode verifikasi dikirim ulang.'), findsOneWidget);
    });

    testWidgets('resend button shows error snackbar on failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildVerifyScreen(
          email: 'test@campus.id',
          authOverride: FailingResendAuth(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kirim ulang kode'));
      await tester.pumpAndSettle();

      expect(find.text('Simulasi error kirim ulang'), findsOneWidget);
    });

    testWidgets('back button pops the screen', (tester) async {
      await tester.pumpWidget(buildVerifyScreen(email: 'test@campus.id'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    });

    testWidgets('Masuk button is present and tappable', (tester) async {
      await tester.pumpWidget(buildVerifyScreen(email: 'test@campus.id'));
      await tester.pumpAndSettle();

      expect(find.text('Sudah verifikasi? Masuk'), findsOneWidget);

      await tester.tap(find.text('Sudah verifikasi? Masuk'));
      await tester.pumpAndSettle();

      expect(find.byType(VerifyEmailScreen), findsOneWidget);
    });
  });
}
