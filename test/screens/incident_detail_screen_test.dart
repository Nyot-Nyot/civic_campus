import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/api/incident_api.dart';
import 'package:civic_campus/api/report_api.dart';
import 'package:civic_campus/api/storage_service.dart';
import 'package:civic_campus/core/api_client.dart';
import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/data/providers/report_provider.dart';
import 'package:civic_campus/screens/shared/incident/detail/incident_detail_screen.dart';
import '../test_helper.dart';

class FailingIncidentApi extends IncidentApi {
  FailingIncidentApi(super.client);

  @override
  Future<ApiResponse> update(String id, Map<String, dynamic> data) async {
    return ApiResponse.error('Simulasi error dari server');
  }
}

Widget buildDetailScreen({
  required Incident incident,
  bool showAdminActions = false,
  bool showStaffActions = false,
  bool failUpdate = false,
}) {
  final apiClient = MockApiClient();
  final incidentApi =
      failUpdate ? FailingIncidentApi(apiClient) : IncidentApi(apiClient);
  final reportApi = ReportApi(apiClient);
  final storageService = StorageService(apiClient);

  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<IncidentProvider>(
          create: (_) => IncidentProvider(incidentApi),
        ),
        ChangeNotifierProvider<ReportProvider>(
          create: (_) => ReportProvider(reportApi: reportApi, storage: storageService),
        ),
      ],
      child: IncidentDetailScreen(
        incident: incident,
        showAdminActions: showAdminActions,
        showStaffActions: showStaffActions,
      ),
    ),
  );
}

void main() {
  final openIncident = Incident(
    id: 'test-1',
    title: 'AC Rusak',
    location: 'A101',
    category: 'AC',
    status: statusOpen,
    timeAgo: '2 jam lalu',
    createdAt: DateTime.now(),
  );

  final resolvedIncident = Incident(
    id: 'test-2',
    title: 'AC Rusak',
    location: 'A101',
    category: 'AC',
    status: statusResolved,
    timeAgo: '2 jam lalu',
    createdAt: DateTime.now(),
  );

  final assignedIncident = Incident(
    id: 'test-3',
    title: 'AC Rusak',
    location: 'A101',
    category: 'AC',
    status: statusAssigned,
    timeAgo: '2 jam lalu',
    createdAt: DateTime.now(),
  );

  group('Admin sticky buttons', () {
    testWidgets('Open incident shows Assign button', (tester) async {
      await tester.pumpWidget(
        buildDetailScreen(
          incident: openIncident,
          showAdminActions: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assign'), findsOneWidget);
    });

    testWidgets('Assigned incident shows Tugaskan Ulang button', (tester) async {
      await tester.pumpWidget(
        buildDetailScreen(
          incident: assignedIncident,
          showAdminActions: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tugaskan Ulang'), findsOneWidget);
    });

    testWidgets('Resolved incident shows Tutup Insiden button', (tester) async {
      await tester.pumpWidget(
        buildDetailScreen(
          incident: resolvedIncident,
          showAdminActions: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tutup Insiden'), findsOneWidget);
    });
  });

  group('Error snackbar', () {
    testWidgets('shows API error when admin Tutup Insiden fails', (tester) async {
      await tester.pumpWidget(
        buildDetailScreen(
          incident: resolvedIncident,
          showAdminActions: true,
          failUpdate: true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tutup Insiden'));
      await tester.pumpAndSettle();

      expect(find.text('Simulasi error dari server'), findsOneWidget);
    });

    testWidgets('shows Buat RAB button for assigned incident (staff)', (tester) async {
      await tester.pumpWidget(
        buildDetailScreen(
          incident: assignedIncident,
          showStaffActions: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buat RAB'), findsOneWidget);
    });
  });

  group('Staff sticky buttons', () {
    testWidgets('Assigned incident shows Buat RAB for staff', (tester) async {
      await tester.pumpWidget(
        buildDetailScreen(
          incident: assignedIncident,
          showStaffActions: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buat RAB'), findsOneWidget);
    });
  });
}
