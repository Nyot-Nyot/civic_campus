import 'package:civic_campus/api/api.dart';
import 'package:civic_campus/core/api_client.dart';
import 'package:civic_campus/core/auth_service.dart';
import 'package:civic_campus/data/providers/auth_provider.dart';
import 'package:civic_campus/data/providers/category_provider.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/data/providers/location_provider.dart';
import 'package:civic_campus/data/providers/notification_provider.dart';
import 'package:civic_campus/data/providers/report_provider.dart';
import 'package:civic_campus/data/providers/user_provider.dart';
import 'package:civic_campus/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.local');

  final apiClient = ApiClient();
  final authService = AuthService(client: apiClient);
  await authService.init();

  final incidentApi = IncidentApi(apiClient);
  final reportApi = ReportApi(apiClient);
  final locationApi = LocationApi(apiClient);
  final categoryApi = CategoryApi(apiClient);
  final userApi = UserApi(apiClient);
  final notificationApi = NotificationApi(apiClient);
  final storageService = StorageService(apiClient);

  runApp(
    MultiProvider(
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
      child: const CivicCampusApp(),
    ),
  );
}
