import '../core/api_client.dart';
import '../core/api_config.dart';

class BudgetApi {
  final ApiClient _client;

  BudgetApi(this._client);

  Future<ApiResponse> listForIncident(String incidentId) {
    return _client.get(
      '${ApiConfig.restUrl}/budget_requests',
      queryParams: {
        'incident_id': 'eq.$incidentId',
        'order': 'version.desc',
      },
    );
  }

  Future<ApiResponse> getPending() {
    return _client.get(
      '${ApiConfig.restUrl}/budget_requests',
      queryParams: {
        'status': 'eq.Menunggu',
        'order': 'created_at.asc',
        'select': '*,incident:incident_id(*)',
      },
    );
  }

  Future<ApiResponse> create(Map<String, dynamic> data) {
    return _client.post('${ApiConfig.restUrl}/budget_requests', body: data);
  }

  Future<ApiResponse> approve(String id, String adminNotes) {
    return _client.patch(
      '${ApiConfig.restUrl}/budget_requests',
      body: {
        'status': 'Disetujui',
        'admin_notes': adminNotes,
      },
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> reject(String id, String adminNotes) {
    return _client.patch(
      '${ApiConfig.restUrl}/budget_requests',
      body: {
        'status': 'Ditolak',
        'admin_notes': adminNotes,
      },
      queryParams: {'id': 'eq.$id'},
    );
  }
}
