import '../core/api_client.dart';
import '../core/api_config.dart';

class UserApi {
  final ApiClient _client;

  UserApi(this._client);

  Future<ApiResponse> list({bool? activeOnly, String? role, String? search}) async {
    final params = <String, String>{'order': 'name.asc'};
    if (activeOnly == true) params['is_active'] = 'eq.true';
    if (role != null) params['role'] = 'eq.$role';
    if (search != null) params['name'] = 'ilike.*$search*';
    return _client.get(
      '${ApiConfig.restUrl}/profiles',
      queryParams: params,
    );
  }

  Future<ApiResponse> getById(String id) async {
    return _client.get(
      '${ApiConfig.restUrl}/profiles',
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> create(Map<String, dynamic> data) async {
    return _client.post('${ApiConfig.restUrl}/profiles', body: data);
  }

  Future<ApiResponse> update(String id, Map<String, dynamic> data) async {
    return _client.patch(
      '${ApiConfig.restUrl}/profiles',
      body: data,
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> toggleActive(String id, bool isActive) async {
    return update(id, {'is_active': isActive});
  }
}
