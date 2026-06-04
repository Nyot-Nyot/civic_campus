import 'package:flutter/foundation.dart';
import 'package:civic_campus/api/user_api.dart';

class UserProvider extends ChangeNotifier {
  final UserApi _api;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;

  UserProvider(this._api);

  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load({bool? activeOnly, String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.list(activeOnly: activeOnly, role: role);
    if (response.isSuccess && response.data is List) {
      _users = (response.data as List).cast<Map<String, dynamic>>();
    } else {
      _error = response.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> create(Map<String, dynamic> data) async {
    final response = await _api.create(data);
    if (response.isSuccess) {
      await load();
      return null;
    }
    return response.error;
  }

  Future<String?> update(String id, Map<String, dynamic> data) async {
    final response = await _api.update(id, data);
    if (response.isSuccess) {
      await load();
      return null;
    }
    return response.error;
  }

  Future<String?> toggleActive(String id, bool isActive) async {
    final response = await _api.toggleActive(id, isActive);
    if (response.isSuccess) {
      await load();
      return null;
    }
    return response.error;
  }

  List<Map<String, dynamic>> getStaff() {
    return _users.where((u) => u['role'] == 'Maintenance Staff').toList();
  }

  List<Map<String, dynamic>> getAdmins() {
    return _users.where((u) => u['role'] == 'Facility Admin' || u['role'] == 'Super Admin').toList();
  }
}
