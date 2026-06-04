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

    Map<String, dynamic>? uploadResult;
    if (photoBytes != null && photoFileName != null) {
      final uploadResp = await _storage.uploadPhoto(photoBytes, fileName: photoFileName);
      if (uploadResp.isError) {
        _error = uploadResp.error;
        _isSubmitting = false;
        notifyListeners();
        return uploadResp.error;
      }
      uploadResult = uploadResp.data as Map<String, dynamic>?;
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

      if (uploadResult != null) {
        final innerData = _lastResult?['data'] as Map<String, dynamic>?;
        final reportId = innerData?['report_id'] as String?;
        final key = uploadResult['key'] as String?;
        final url = uploadResult['url'] as String?;
        if (reportId != null && key != null && url != null) {
          await _reportApi.createAttachment(
            reportId: reportId,
            storageKey: key,
            storageUrl: url,
          );
        }
      }

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

  Future<List<String>> getIncidentPhotoUrls(String incidentId) async {
    final response = await _reportApi.getIncidentPhotos(incidentId);
    final urls = <String>[];
    if (response.isSuccess && response.data is List) {
      for (final report in response.data as List) {
        final attachments = report['report_attachments'] as List?;
        if (attachments != null) {
          for (final att in attachments) {
            final url = att['storage_url'] as String?;
            if (url != null && url.isNotEmpty) urls.add(url);
          }
        }
      }
    }
    return urls;
  }

  void reset() {
    _error = null;
    _lastResult = null;
    _isSubmitting = false;
    notifyListeners();
  }
}
