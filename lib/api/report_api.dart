import '../core/api_client.dart';
import '../core/api_config.dart';

class ReportApi {
  final ApiClient _client;

  ReportApi(this._client);

  Future<ApiResponse> submit({
    required String locationId,
    String? locationDetails,
    required String categoryId,
    String? description,
    String? existingIncidentId,
  }) async {
    return _client.post(
      '${ApiConfig.functionsUrl}/submit-report',
      body: {
        'location_id': locationId,
        'location_details': locationDetails ?? '',
        'category_id': categoryId,
        'description': description ?? '',
        'existing_incident_id': ?existingIncidentId,
      },
    );
  }

  Future<ApiResponse> checkDuplicates({
    required String locationId,
    required String categoryId,
    String? description,
  }) async {
    return _client.post(
      '${ApiConfig.functionsUrl}/check-duplicates',
      body: {
        'location_id': locationId,
        'category_id': categoryId,
        'description': description ?? '',
      },
    );
  }

  Future<ApiResponse> confirm(String incidentId, {String? comment}) async {
    return _client.post(
      '${ApiConfig.restUrl}/confirmations',
      body: {
        'incident_id': incidentId,
        'comment': ?comment,
      },
    );
  }

  Future<ApiResponse> createAttachment({
    required String reportId,
    required String storageKey,
    required String storageUrl,
    String? mimeType,
  }) async {
    return _client.post(
      '${ApiConfig.restUrl}/report_attachments',
      body: {
        'report_id': reportId,
        'storage_key': storageKey,
        'storage_url': storageUrl,
        'mime_type': mimeType ?? 'image/jpeg',
      },
    );
  }

  Future<ApiResponse> getAttachments(String reportId) async {
    return _client.get(
      '${ApiConfig.restUrl}/report_attachments',
      queryParams: {'report_id': 'eq.$reportId'},
    );
  }

  Future<ApiResponse> getIncidentPhotos(String incidentId) async {
    return _client.get(
      '${ApiConfig.restUrl}/reports',
      queryParams: {
        'incident_id': 'eq.$incidentId',
        'select': 'id,report_attachments(storage_url,storage_key)',
      },
    );
  }

  Future<ApiResponse> getReports({String? userId, String? incidentId, int? limit, int? offset}) async {
    final params = <String, String>{
      'order': 'created_at.desc',
    };
    if (userId != null) params['user_id'] = 'eq.$userId';
    if (incidentId != null) params['incident_id'] = 'eq.$incidentId';
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();
    return _client.get(
      '${ApiConfig.restUrl}/reports',
      queryParams: params,
    );
  }
}
