import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import 'api_config.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String? profileId;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    this.profileId,
  });

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user_id': userId,
        'email': email,
        'profile_id': profileId,
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        userId: json['user_id'] as String,
        email: json['email'] as String,
        profileId: json['profile_id'] as String?,
      );
}

class AuthService extends ChangeNotifier {
  final ApiClient _client;
  final FlutterSecureStorage _storage;
  AuthSession? _session;
  bool _isLoading = false;

  AuthService({
    required ApiClient client,
    FlutterSecureStorage? storage,
  })  : _client = client,
        _storage = storage ?? const FlutterSecureStorage();

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

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _client.post(
      '${ApiConfig.authUrl}/token?grant_type=password',
      body: {
        'email': email,
        'password': password,
      },
    );

    _isLoading = false;

    if (response.isError) {
      notifyListeners();
      return response.error;
    }

    final data = response.data as Map<String, dynamic>;
    _session = AuthSession(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      userId: data['user']['id'] as String,
      email: data['user']['email'] as String,
    );
    _client.setAccessToken(_session!.accessToken);
    await _persistSession();
    notifyListeners();
    return null;
  }

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _client.post(
      '${ApiConfig.authUrl}/signup',
      body: {
        'email': email,
        'password': password,
      },
    );

    _isLoading = false;

    if (response.isError) {
      notifyListeners();
      return response.error;
    }

    return null;
  }

  Future<void> signOut() async {
    await _client.post('${ApiConfig.authUrl}/logout');
    _session = null;
    _client.setAccessToken(null);
    await _storage.delete(key: 'auth_session');
    notifyListeners();
  }

  Future<String?> refreshSession() async {
    if (_session == null) return 'Not authenticated';

    final response = await _client.post(
      '${ApiConfig.authUrl}/token?grant_type=refresh_token',
      body: {'refresh_token': _session!.refreshToken},
    );

    if (response.isError) return response.error;

    final data = response.data as Map<String, dynamic>;
    _session = AuthSession(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
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
    final params = _session!.toJson().entries.map((e) => '${e.key}=${e.value}').join('&');
    await _storage.write(key: 'auth_session', value: params);
  }
}
