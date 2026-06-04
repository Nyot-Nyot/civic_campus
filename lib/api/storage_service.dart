import '../core/api_client.dart';
import '../core/api_config.dart';

class StorageService {
  final ApiClient _client;

  StorageService(this._client);

  Future<ApiResponse> uploadPhoto(
    List<int> bytes, {
    required String fileName,
    String bucket = 'incident-photos',
    String? mimeType,
  }) async {
    final url = '${ApiConfig.storageUrl}/buckets/$bucket/objects/$fileName';
    return _client.uploadFile(url, bytes, mimeType: mimeType ?? 'image/jpeg', method: 'PUT', fileName: fileName);
  }

  Future<ApiResponse> uploadPhotoWithKey(
    List<int> bytes, {
    required String key,
    String bucket = 'incident-photos',
    String? mimeType,
  }) async {
    return uploadPhoto(bytes, fileName: key, bucket: bucket, mimeType: mimeType);
  }

  String getPublicUrl(String key, {String bucket = 'incident-photos'}) {
    return '${ApiConfig.storageUrl}/buckets/$bucket/objects/$key';
  }

  Future<ApiResponse> deletePhoto(String key, {String bucket = 'incident-photos'}) async {
    return _client.delete('${ApiConfig.storageUrl}/buckets/$bucket/objects/$key');
  }
}
