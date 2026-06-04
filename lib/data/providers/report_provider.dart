import 'package:flutter/foundation.dart';
import 'package:civic_campus/api/report_api.dart';
import 'package:civic_campus/api/storage_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportApi _reportApi;
  final StorageService _storage;

  bool _isSubmitting = false;
  String? _error;
  Map<String, dynamic>? _lastResult;

  ReportProvider({
    required this._reportApi,
    required this._storage,
  });

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  Map<String, dynamic>? get lastResult => _lastResult;

  Future<String?> submit({
    required String locationId,
    String? locationDetails,
    required String categoryId,
    String? description,
    String? existingIncidentId,
    List<int>? photoBytes,
    String? photoFileName,
  }) async {
    _isSubmitting = true;
    _error = null;
    _lastResult = null;
    notifyListeners();

    if (photoBytes != null && photoFileName != null) {
      final uploadResp = await _storage.uploadPhoto(photoBytes, fileName: photoFileName);
      if (uploadResp.isError) {
        _error = uploadResp.error;
        _isSubmitting = false;
        notifyListeners();
        return uploadResp.error;
      }
    }

    final response = await _reportApi.submit(
      locationId: locationId,
      locationDetails: locationDetails,
      categoryId: categoryId,
      description: description,
      existingIncidentId: existingIncidentId,
    );

    _isSubmitting = false;

    if (response.isSuccess && response.data is Map) {
      _lastResult = response.data as Map<String, dynamic>?;
      notifyListeners();
      return null;
    }

    _error = response.error;
    notifyListeners();
    return response.error;
  }

  Future<List<Map<String, dynamic>>> checkDuplicates({
    required String locationId,
    required String categoryId,
    String? description,
  }) async {
    final response = await _reportApi.checkDuplicates(
      locationId: locationId,
      categoryId: categoryId,
      description: description,
    );
    if (response.isSuccess) {
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  void reset() {
    _error = null;
    _lastResult = null;
    _isSubmitting = false;
    notifyListeners();
  }
}
