import 'package:flutter/foundation.dart';
import 'package:civic_campus/core/auth_service.dart';
import 'package:civic_campus/api/user_api.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserApi _userApi;

  Map<String, dynamic>? _profile;
  bool _isLoadingProfile = false;
  String? _profileError;

  AuthProvider({
    required this._authService,
    required this._userApi,
  });

  AuthService get authService => _authService;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get profileError => _profileError;
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get userId => _authService.userId;
  String? get accessToken => _authService.session?.accessToken;

  bool get needsEmailVerification => _authService.needsEmailVerification;
  bool get signUpSucceeded => _authService.signUpSucceeded;

  Future<String?> signIn(String email, String password) {
    return _authService.signIn(email: email, password: password);
  }

  Future<String?> verifyEmail(String email, String otp) {
    return _authService.verifyEmail(email, otp);
  }

  Future<String?> resendVerificationEmail(String email) {
    return _authService.resendVerificationEmail(email);
  }

  Future<String?> signUp(String email, String password, {String? name}) {
    return _authService.signUp(email: email, password: password, name: name);
  }

  /// Returns `null` on success. Returns `'VERIFICATION_REQUIRED'` when
  /// sign-up succeeded but email verification is required (no session created).
  Future<String?> signUpWithProfile({
    required String email,
    required String password,
    required String name,
  }) async {
    final error = await _authService.signUp(email: email, password: password, name: name);
    if (error != null) return error;

    final uid = _authService.userId;
    if (uid == null) return 'VERIFICATION_REQUIRED';

    final profileResponse = await _userApi.create({
      'id': uid,
      'name': name,
      'role': 'Student',
    });
    if (profileResponse.isError) return profileResponse.error;

    await loadProfile();
    return null;
  }

  Future<void> signOut() async {
    _profile = null;
    await _authService.signOut();
    notifyListeners();
  }

  Future<void> loadProfile() async {
    if (_authService.userId == null) return;
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    final response = await _userApi.getById(_authService.userId!);
    if (response.isSuccess && response.data is List && (response.data as List).isNotEmpty) {
      _profile = (response.data as List).first as Map<String, dynamic>;
    } else {
      _profileError = response.error;
    }
    _isLoadingProfile = false;
    notifyListeners();
  }

  Future<String?> updateProfile(Map<String, dynamic> data) async {
    final uid = _authService.userId;
    if (uid == null) return 'Not authenticated';
    final response = await _userApi.update(uid, data);
    if (response.isSuccess) {
      await loadProfile();
      return null;
    }
    return response.error;
  }
}
