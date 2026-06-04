import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'api_config.dart';

class ApiClient {
  String? _accessToken;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'apikey': ApiConfig.anonKey,
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Future<ApiResponse> get(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final mergedHeaders = {..._headers, ...?headers};
      final response = await http.post(
        Uri.parse(url),
        headers: mergedHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse> patch(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.patch(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse> delete(String url) async {
    try {
      final response = await http.delete(Uri.parse(url), headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse> uploadFile(
    String url,
    List<int> bytes, {
    required String mimeType,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(_headers);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        contentType: MediaType.parse(mimeType),
      ));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null);
      }
      return ApiResponse.success(jsonDecode(response.body));
    }
    return ApiResponse.error(
      _parseError(response),
      statusCode: response.statusCode,
    );
  }

  String _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        return body['message'] as String? ??
            body['error'] as String? ??
            body['msg'] as String? ??
            response.reasonPhrase ??
            'Unknown error';
      }
      return response.reasonPhrase ?? 'Unknown error';
    } catch (_) {
      return response.reasonPhrase ?? 'Unknown error';
    }
  }

  String _formatError(Object e) {
    if (e is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }
    if (e is http.ClientException) {
      return 'Gagal terhubung ke server: ${e.message}';
    }
    return 'Terjadi kesalahan: $e';
  }
}

class ApiResponse {
  final dynamic data;
  final String? error;
  final int? statusCode;

  ApiResponse._({this.data, this.error, this.statusCode});

  factory ApiResponse.success(dynamic data) {
    return ApiResponse._(data: data);
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse._(error: error, statusCode: statusCode);
  }

  bool get isSuccess => error == null;
  bool get isError => error != null;
}
