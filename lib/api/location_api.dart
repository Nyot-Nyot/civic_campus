import '../core/api_client.dart';
import '../core/api_config.dart';

class LocationApi {
  final ApiClient _client;

  LocationApi(this._client);

  Future<ApiResponse> getBuildings() async {
    return _client.get(
      '${ApiConfig.restUrl}/locations',
      queryParams: {'type': 'eq.Building', 'order': 'name.asc'},
    );
  }

  Future<ApiResponse> getFloors(String buildingId) async {
    return _client.get(
      '${ApiConfig.restUrl}/locations',
      queryParams: {
        'type': 'eq.Floor',
        'parent_id': 'eq.$buildingId',
        'order': 'name.asc',
      },
    );
  }

  Future<ApiResponse> getAreas(String floorId) async {
    return _client.get(
      '${ApiConfig.restUrl}/locations',
      queryParams: {
        'type': 'eq.Area',
        'parent_id': 'eq.$floorId',
        'order': 'name.asc',
      },
    );
  }

  Future<ApiResponse> getById(String id) async {
    return _client.get(
      '${ApiConfig.restUrl}/locations',
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> create(Map<String, dynamic> data) async {
    return _client.post('${ApiConfig.restUrl}/locations', body: data);
  }

  Future<ApiResponse> update(String id, Map<String, dynamic> data) async {
    return _client.patch(
      '${ApiConfig.restUrl}/locations',
      body: data,
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> delete(String id) async {
    return _client.delete('${ApiConfig.restUrl}/locations?id=eq.$id');
  }
}
