import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';
import 'api_config.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'user_id': userId,
    'email': email,
  };

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    userId: json['user_id'] as String,
    email: json['email'] as String,
  );
}

class AuthService extends ChangeNotifier {
  final ApiClient _client;
  final FlutterSecureStorage _storage;
  AuthSession? _session;
  bool _isLoading = false;

  AuthService({required this._client, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get userId => _session?.userId;

  Future<void> init() async {
    final saved = await _storage.read(key: 'auth_session');
    if (saved != null) {
      try {
        final json = Map<String, dynamic>.from(
          Uri.splitQueryString(saved.replaceAll('&', '\n')),
        );
        _session = AuthSession.fromJson(json);
        _client.setAccessToken(_session!.accessToken);
      } catch (_) {
        await _storage.delete(key: 'auth_session');
      }
    }
  }

  /// Returns `null` on success, error string on failure.
  /// Sets [needsEmailVerification] if sign-in fails because email is not verified.
  bool needsEmailVerification = false;

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    needsEmailVerification = false;
    notifyListeners();

    final response = await _client.post(
      '${ApiConfig.baseUrl}/api/auth/sessions?client_type=mobile',
      body: {'email': email, 'password': password},
    );

    _isLoading = false;

    if (response.isError) {
      notifyListeners();
      if (response.statusCode == 403) {
        needsEmailVerification = true;
      }
      return response.error;
    }

    final data = response.data as Map<String, dynamic>;
    _session = AuthSession(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String? ?? '',
      userId: data['user']['id'] as String,
      email: data['user']['email'] as String,
    );
    _client.setAccessToken(_session!.accessToken);
    await _persistSession();
    notifyListeners();
    return null;
  }

  /// Returns `null` on success. If email verification is required, returns
  /// `null` and sets [needsEmailVerification] to `true` if the user was
  /// created but not issued a session. API errors about "already exists" or
  /// "confirmation" are treated as verification-required when reasonable.
  bool signUpSucceeded = false;

  Future<String?> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    _isLoading = true;
    signUpSucceeded = false;
    notifyListeners();

    final response = await _client.post(
      '${ApiConfig.baseUrl}/api/auth/users?client_type=mobile',
      body: {'email': email, 'password': password, 'name': ?name},
    );

    _isLoading = false;

    if (response.isError) {
      final errMsg = response.error ?? '';
      final isVerificationErr = errMsg.toLowerCase().contains('confirm') ||
          errMsg.toLowerCase().contains('verif') ||
          errMsg.toLowerCase().contains('sudah terdaftar') ||
          errMsg.toLowerCase().contains('already exists');
      if (isVerificationErr) {
        needsEmailVerification = true;
        signUpSucceeded = true;
        notifyListeners();
        return null;
      }
      notifyListeners();
      return response.error;
    }

    final data = response.data as Map<String, dynamic>;
    if (data['accessToken'] != null) {
      _session = AuthSession(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String? ?? '',
        userId: data['user']['id'] as String,
        email: data['user']['email'] as String,
      );
      _client.setAccessToken(_session!.accessToken);
      await _persistSession();
    } else {
      needsEmailVerification = true;
    }

    signUpSucceeded = true;
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    await _client.post('${ApiConfig.baseUrl}/api/auth/logout');
    _session = null;
    _client.setAccessToken(null);
    await _storage.delete(key: 'auth_session');
    notifyListeners();
  }

  /// Submits OTP code for email verification. On success, user is
  /// automatically signed in (session is saved).
  Future<String?> verifyEmail(String email, String otp) async {
    final response = await _client.post(
      '${ApiConfig.baseUrl}/api/auth/email/verify?client_type=mobile',
      body: {'email': email, 'otp': otp},
    );
    if (response.isError) return response.error;

    final data = response.data as Map<String, dynamic>;
    if (data['accessToken'] != null) {
      _session = AuthSession(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String? ?? '',
        userId: data['user']['id'] as String,
        email: data['user']['email'] as String,
      );
      _client.setAccessToken(_session!.accessToken);
      await _persistSession();
      needsEmailVerification = false;
    }
    notifyListeners();
    return null;
  }

  Future<String?> resendVerificationEmail(String email) async {
    final response = await _client.post(
      '${ApiConfig.baseUrl}/api/auth/email/send-verification',
      body: {'email': email},
    );
    return response.error;
  }

  Future<String?> refreshSession() async {
    if (_session == null || _session!.refreshToken.isEmpty) {
      return 'Not authenticated';
    }

    final response = await _client.post(
      '${ApiConfig.baseUrl}/api/auth/refresh?client_type=mobile',
      body: {'refreshToken': _session!.refreshToken},
    );

    if (response.isError) return response.error;

    final data = response.data as Map<String, dynamic>;
    _session = AuthSession(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String? ?? _session!.refreshToken,
      userId: data['user']['id'] as String,
      email: data['user']['email'] as String,
    );
    _client.setAccessToken(_session!.accessToken);
    await _persistSession();
    notifyListeners();
    return null;
  }

  Future<void> _persistSession() async {
    if (_session == null) return;
    final params = _session!
        .toJson()
        .entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    await _storage.write(key: 'auth_session', value: params);
  }
}
