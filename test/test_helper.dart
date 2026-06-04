import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/api/category_api.dart';
import 'package:civic_campus/api/incident_api.dart';
import 'package:civic_campus/api/location_api.dart';
import 'package:civic_campus/api/notification_api.dart';
import 'package:civic_campus/api/report_api.dart';
import 'package:civic_campus/api/storage_service.dart';
import 'package:civic_campus/api/user_api.dart';
import 'package:civic_campus/core/api_client.dart';
import 'package:civic_campus/core/auth_service.dart';
import 'package:civic_campus/data/providers/auth_provider.dart';
import 'package:civic_campus/data/providers/category_provider.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/data/providers/location_provider.dart';
import 'package:civic_campus/data/providers/notification_provider.dart';
import 'package:civic_campus/data/providers/report_provider.dart';
import 'package:civic_campus/data/providers/user_provider.dart';

class MockApiClient extends ApiClient {
  MockApiClient() : super();

  @override
  Future<ApiResponse> get(String url, {Map<String, String>? queryParams}) async {
    return ApiResponse.success([]);
  }

  @override
  Future<ApiResponse> post(String url, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return ApiResponse.success({});
  }

  @override
  Future<ApiResponse> patch(String url, {Map<String, dynamic>? body, Map<String, String>? queryParams}) async {
    return ApiResponse.success({});
  }

  @override
  Future<ApiResponse> delete(String url) async {
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse> uploadFile(String url, List<int> bytes, {required String mimeType, String method = 'POST', String? fileName}) async {
    return ApiResponse.success({'url': 'https://test.url/photo.jpg', 'key': 'test-key'});
  }
}

class MockAuthService extends AuthService {
  MockAuthService() : super(client: MockApiClient());

  @override
  bool get isAuthenticated => false;

  @override
  String? get userId => null;

  @override
  Future<String?> signIn({required String email, required String password}) async {
    return null;
  }

  @override
  Future<void> signOut() async {}
}

Future<void> initTestEnv() async {
  await dotenv.load(fileName: '.env.local');
}

Future<Widget> wrapAppWithProviders({required Widget child}) async {
  await initTestEnv();
  return wrapWithProviders(child: child);
}

Widget wrapWithProviders({required Widget child}) {
  final apiClient = MockApiClient();
  final authService = MockAuthService();
  final incidentApi = IncidentApi(apiClient);
  final reportApi = ReportApi(apiClient);
  final locationApi = LocationApi(apiClient);
  final categoryApi = CategoryApi(apiClient);
  final userApi = UserApi(apiClient);
  final notificationApi = NotificationApi(apiClient);
  final storageService = StorageService(apiClient);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(authService: authService, userApi: userApi),
      ),
      ChangeNotifierProvider<IncidentProvider>(
        create: (_) => IncidentProvider(incidentApi),
      ),
      ChangeNotifierProvider<LocationProvider>(
        create: (_) => LocationProvider(locationApi),
      ),
      ChangeNotifierProvider<CategoryProvider>(
        create: (_) => CategoryProvider(categoryApi),
      ),
      ChangeNotifierProvider<UserProvider>(
        create: (_) => UserProvider(userApi),
      ),
      ChangeNotifierProvider<NotificationProvider>(
        create: (_) => NotificationProvider(notificationApi),
      ),
      ChangeNotifierProvider<ReportProvider>(
        create: (_) => ReportProvider(reportApi: reportApi, storage: storageService),
      ),
    ],
    child: child,
  );
}
