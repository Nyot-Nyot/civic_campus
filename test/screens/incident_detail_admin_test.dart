import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/screens/shared/incident/detail/incident_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helper.dart';

void main() {
  group('Admin sticky button labels per status', () {
    testWidgets('Open incident shows "Assign" button', (tester) async {
      final incident = Incident(
        id: '1',
        title: 'Test Incident',
        location: 'Test Location',
        category: 'Test Category',
        status: statusOpen,
        timeAgo: '2 jam lalu',
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          child: MaterialApp(
            home: IncidentDetailScreen(
              incident: incident,
              showAdminActions: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assign'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_alt_1), findsOneWidget);
    });

    testWidgets('Assigned incident shows "Tugaskan Ulang" button', (tester) async {
      final incident = Incident(
        id: '2',
        title: 'Test Incident',
        location: 'Test Location',
        category: 'Test Category',
        status: statusAssigned,
        timeAgo: '2 jam lalu',
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          child: MaterialApp(
            home: IncidentDetailScreen(
              incident: incident,
              showAdminActions: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tugaskan Ulang'), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('Resolved incident shows "Tutup Insiden" button', (tester) async {
      final incident = Incident(
        id: '3',
        title: 'Test Incident',
        location: 'Test Location',
        category: 'Test Category',
        status: statusResolved,
        timeAgo: '2 jam lalu',
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          child: MaterialApp(
            home: IncidentDetailScreen(
              incident: incident,
              showAdminActions: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tutup Insiden'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('Closed incident has no sticky button', (tester) async {
      final incident = Incident(
        id: '4',
        title: 'Test Incident',
        location: 'Test Location',
        category: 'Test Category',
        status: statusClosed,
        timeAgo: '2 jam lalu',
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          child: MaterialApp(
            home: IncidentDetailScreen(
              incident: incident,
              showAdminActions: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assign'), findsNothing);
      expect(find.text('Tugaskan Ulang'), findsNothing);
      expect(find.text('Tutup Insiden'), findsNothing);
    });

    testWidgets('In Progress incident has no admin sticky button', (tester) async {
      final incident = Incident(
        id: '5',
        title: 'Test Incident',
        location: 'Test Location',
        category: 'Test Category',
        status: statusInProgress,
        timeAgo: '2 jam lalu',
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          child: MaterialApp(
            home: IncidentDetailScreen(
              incident: incident,
              showAdminActions: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assign'), findsNothing);
      expect(find.text('Tugaskan Ulang'), findsNothing);
      expect(find.text('Tutup Insiden'), findsNothing);
    });
  });

  group('Update Status button', () {
    testWidgets('is visible for admin on non-terminal incidents', (tester) async {
      final incident = Incident(
        id: '6',
        title: 'Test Incident',
        location: 'Test Location',
        category: 'Test Category',
        status: statusOpen,
        timeAgo: '2 jam lalu',
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          child: MaterialApp(
            home: IncidentDetailScreen(
              incident: incident,
              showAdminActions: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Update Status'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Update Status'), findsOneWidget);
    });

    testWidgets('is absent for admin on Closed incidents', (tester) async {
      final incident = Incident(
        id: '7',
        title: 'Test Incident',
        location: 'Test Location',
        category: 'Test Category',
        status: statusClosed,
        timeAgo: '2 jam lalu',
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          child: MaterialApp(
            home: IncidentDetailScreen(
              incident: incident,
              showAdminActions: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Update Status'), findsNothing);
    });
  });
}
