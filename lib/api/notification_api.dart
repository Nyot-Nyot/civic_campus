import '../core/api_client.dart';
import '../core/api_config.dart';

class NotificationApi {
  final ApiClient _client;

  NotificationApi(this._client);

  Future<ApiResponse> list({String? userId, int? limit, int? offset}) async {
    final params = <String, String>{
      'order': 'created_at.desc',
    };
    if (userId != null) params['user_id'] = 'eq.$userId';
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();
    return _client.get(
      '${ApiConfig.restUrl}/notifications',
      queryParams: params,
    );
  }

  Future<ApiResponse> getUnreadCount(String userId) async {
    return _client.get(
      '${ApiConfig.restUrl}/notifications',
      queryParams: {
        'user_id': 'eq.$userId',
        'read_at': 'is.null',
        'select': 'count',
      },
    );
  }

  Future<ApiResponse> markRead(String id) async {
    return _client.patch(
      '${ApiConfig.restUrl}/notifications',
      body: {'read_at': 'now()'},
      queryParams: {'id': 'eq.$id'},
    );
  }

  Future<ApiResponse> markAllRead(String userId) async {
    return _client.patch(
      '${ApiConfig.restUrl}/notifications',
      body: {'read_at': 'now()'},
      queryParams: {'user_id': 'eq.$userId', 'read_at': 'is.null'},
    );
  }
}
