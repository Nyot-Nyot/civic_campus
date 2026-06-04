import 'package:flutter/foundation.dart';
import 'package:civic_campus/api/category_api.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryApi _api;

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider(this._api);

  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.list();
    if (response.isSuccess && response.data is List) {
      _categories = (response.data as List).cast<Map<String, dynamic>>();
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

  Future<String?> delete(String id) async {
    final response = await _api.delete(id);
    if (response.isSuccess) {
      await load();
      return null;
    }
    return response.error;
  }
}
