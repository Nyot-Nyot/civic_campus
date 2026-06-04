import '../core/api_client.dart';
import '../core/api_config.dart';

class CategoryApi {
  final ApiClient _client;

  CategoryApi(this._client);

  Future<ApiResponse> list() async {
    return _client.get(
      '${ApiConfig.restUrl}/categories',
      queryParams: {'order': 'name.asc'},
    );
  }

  Future<ApiResponse> getById(String id) async {
    return _client.get(
      '${ApiConfig.restUrl}/categories',
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> create(Map<String, dynamic> data) async {
    return _client.post('${ApiConfig.restUrl}/categories', body: data);
  }

  Future<ApiResponse> update(String id, Map<String, dynamic> data) async {
    return _client.patch(
      '${ApiConfig.restUrl}/categories',
      body: data,
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> delete(String id) async {
    return _client.delete('${ApiConfig.restUrl}/categories?id=eq.$id');
  }
}
