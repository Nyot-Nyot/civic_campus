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
    final url = '${ApiConfig.storageUrl}/object/$bucket/$fileName';
    return _client.uploadFile(url, bytes, mimeType: mimeType ?? 'image/jpeg');
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
    return '${ApiConfig.storageUrl}/object/public/$bucket/$key';
  }

  Future<ApiResponse> deletePhoto(String key, {String bucket = 'incident-photos'}) async {
    return _client.delete('${ApiConfig.storageUrl}/object/$bucket/$key');
  }
}
