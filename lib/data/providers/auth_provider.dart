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

  Future<String?> signIn(String email, String password) {
    return _authService.signIn(email: email, password: password);
  }

  Future<String?> signUp(String email, String password, {String? name}) {
    return _authService.signUp(email: email, password: password, name: name);
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
