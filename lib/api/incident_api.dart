import '../core/api_client.dart';
import '../core/api_config.dart';

class IncidentApi {
  final ApiClient _client;

  IncidentApi(this._client);

  Future<ApiResponse> list({
    String? status,
    String? locationId,
    String? categoryId,
    String? assignedTo,
    String? reporterId,
    String? search,
    String? order,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = 'in.($status)';
    if (locationId != null) params['location_id'] = 'eq.$locationId';
    if (categoryId != null) params['category_id'] = 'eq.$categoryId';
    if (assignedTo != null) params['assigned_to'] = 'eq.$assignedTo';
    if (reporterId != null) params['reporter_id'] = 'eq.$reporterId';
    if (order != null) {
      params['order'] = order;
    } else {
      params['order'] = 'updated_at.desc';
    }
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();
    if (search != null) params['title'] = 'ilike.*$search*';

    return _client.get(
      '${ApiConfig.restUrl}/incidents_with_names',
      queryParams: params,
    );
  }

  Future<ApiResponse> getById(String id) async {
    return _client.get(
      '${ApiConfig.restUrl}/incidents_with_names',
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> create(Map<String, dynamic> data) async {
    return _client.post(
      '${ApiConfig.restUrl}/incidents',
      body: data,
    );
  }

  Future<ApiResponse> update(String id, Map<String, dynamic> data) async {
    return _client.patch(
      '${ApiConfig.restUrl}/incidents',
      body: data,
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> updateStatus(String id, String status, {String? notes, String? assignedTo, String? priorityLabel}) async {
    final data = <String, dynamic>{'status': status};
    if (assignedTo != null) data['assigned_to'] = assignedTo;
    if (priorityLabel != null) data['priority_label'] = priorityLabel;
    return update(id, data);
  }

  Future<ApiResponse> getHistory(String incidentId) async {
    return _client.get(
      '${ApiConfig.restUrl}/status_history',
      queryParams: {
        'incident_id': 'eq.$incidentId',
        'order': 'created_at.asc',
      },
    );
  }

  Future<ApiResponse> getNotes(String incidentId) async {
    return _client.get(
      '${ApiConfig.restUrl}/maintenance_notes',
      queryParams: {
        'incident_id': 'eq.$incidentId',
        'order': 'created_at.asc',
      },
    );
  }

  Future<ApiResponse> addNote(String incidentId, String content) async {
    return _client.post(
      '${ApiConfig.restUrl}/maintenance_notes',
      body: {
        'incident_id': incidentId,
        'content': content,
      },
    );
  }
}
