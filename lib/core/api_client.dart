import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'api_config.dart';

class ApiClient {
  String? _accessToken;
  static const _timeout = Duration(seconds: 20);

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

  Future<ApiResponse> _fetch(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error('Permintaan timeout. Coba lagi.');
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse> get(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    return _fetch(() {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      return http.get(uri, headers: _headers);
    });
  }

  Future<ApiResponse> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _fetch(() {
      final mergedHeaders = {..._headers, ...?headers};
      return http.post(
        Uri.parse(url),
        headers: mergedHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<ApiResponse> patch(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    return _fetch(() {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      return http.patch(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<ApiResponse> delete(String url) async {
    return _fetch(() => http.delete(Uri.parse(url), headers: _headers));
  }

  Future<ApiResponse> uploadFile(
    String url,
    List<int> bytes, {
    required String mimeType,
    String method = 'POST',
    String? fileName,
  }) async {
    try {
      final request = http.MultipartRequest(method, Uri.parse(url));
      final headers = Map<String, String>.from(_headers);
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ));
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error('Permintaan timeout. Coba lagi.');
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
