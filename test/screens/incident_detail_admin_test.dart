import 'package:civic_campus/data/dummy_data.dart';
import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/screens/shared/incident/detail/incident_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin sticky button labels per status', () {
    testWidgets('Open incident shows "Assign" button', (tester) async {
      final incident = allIncidents.firstWhere((i) => i.status == statusOpen);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Assign'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_alt_1), findsOneWidget);
    });

    testWidgets('Assigned incident shows "Tugaskan Ulang" button', (tester) async {
      final incident = allIncidents.firstWhere((i) => i.status == statusAssigned);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tugaskan Ulang'), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('Resolved incident shows "Tutup Insiden" button', (tester) async {
      final incident = allIncidents.firstWhere((i) => i.status == statusResolved);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tutup Insiden'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('Closed incident has no sticky button', (tester) async {
      final incident = allIncidents.firstWhere((i) => i.status == statusClosed);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Assign'), findsNothing);
      expect(find.text('Tugaskan Ulang'), findsNothing);
      expect(find.text('Tutup Insiden'), findsNothing);
    });

    testWidgets('In Progress incident has no admin sticky button', (tester) async {
      final incident = allIncidents.firstWhere((i) => i.status == statusInProgress);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Assign'), findsNothing);
      expect(find.text('Tugaskan Ulang'), findsNothing);
      expect(find.text('Tutup Insiden'), findsNothing);
    });
  });

  group('Admin close flow (Resolved → Closed)', () {
    testWidgets('tapping "Tutup Insiden" closes the incident', (tester) async {
      final originalStatus = <String, String>{};
      for (final i in allIncidents) {
        originalStatus[i.id] = i.status;
      }

      final incident = allIncidents.firstWhere((i) => i.status == statusResolved);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tutup Insiden'));
      await tester.pumpAndSettle();

      final updated = allIncidents.firstWhere((i) => i.id == incident.id);
      expect(updated.status, statusClosed);
      expect(find.text('${incident.id} ditutup.'), findsOneWidget);

      for (final i in allIncidents) {
        if (originalStatus.containsKey(i.id)) {
          allIncidents[allIncidents.indexWhere((x) => x.id == i.id)] =
              i.copyWith(status: originalStatus[i.id]!);
        }
      }
    });
  });

  group('Admin assign flow', () {
    testWidgets('tapping "Assign" opens sheet with staff list', (tester) async {
      final incident = allIncidents.firstWhere((i) => i.status == statusOpen);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assign'));
      await tester.pumpAndSettle();

      expect(find.text('Budi Teknisi'), findsOneWidget);
    });

    testWidgets('tapping staff name assigns and shows snackbar', (tester) async {
      final originalStatus = <String, String>{};
      final originalAssignedTo = <String, String?>{};
      for (final i in allIncidents) {
        originalStatus[i.id] = i.status;
        originalAssignedTo[i.id] = i.assignedTo;
      }

      final incident = allIncidents.firstWhere((i) => i.status == statusOpen);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assign'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Budi Teknisi'));
      await tester.pumpAndSettle();

      final updated = allIncidents.firstWhere((i) => i.id == incident.id);
      expect(updated.status, statusAssigned);
      expect(updated.assignedTo, 'Budi Teknisi');
      expect(find.text('Insiden ditugaskan ke Budi Teknisi.'), findsOneWidget);

      for (final i in allIncidents) {
        if (originalStatus.containsKey(i.id)) {
          allIncidents[allIncidents.indexWhere((x) => x.id == i.id)] =
              i.copyWith(
            status: originalStatus[i.id]!,
            assignedTo: originalAssignedTo[i.id],
          );
        }
      }
    });
  });

  group('Admin reject flow', () {
    testWidgets('"Tolak" button is visible for non-terminal incidents', (tester) async {
      final incident = allIncidents.firstWhere((i) => i.status == statusOpen);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Tolak'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Tolak'), findsOneWidget);
    });

    testWidgets('reject with empty reason shows validation snackbar', (tester) async {
      final incident = allIncidents.firstWhere((i) => i.status == statusOpen);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Tolak'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Tolak'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Tolak Insiden'));
      await tester.pumpAndSettle();

      expect(find.text('Alasan harus diisi.'), findsOneWidget);
    });

    testWidgets('reject from Open keeps status Open', (tester) async {
      final originalStatus = <String, String>{};
      for (final i in allIncidents) {
        originalStatus[i.id] = i.status;
      }

      final incident = allIncidents.firstWhere((i) => i.status == statusOpen);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Tolak'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Tolak'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Tidak sesuai prosedur');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Tolak Insiden'));
      await tester.pumpAndSettle();

      final updated = allIncidents.firstWhere((i) => i.id == incident.id);
      expect(updated.status, statusOpen);
      expect(find.text('Insiden ditolak.'), findsOneWidget);

      for (final i in allIncidents) {
        if (originalStatus.containsKey(i.id)) {
          allIncidents[allIncidents.indexWhere((x) => x.id == i.id)] =
              i.copyWith(status: originalStatus[i.id]!);
        }
      }
    });

    testWidgets('reject from Resolved changes status to Assigned', (tester) async {
      final originalStatus = <String, String>{};
      for (final i in allIncidents) {
        originalStatus[i.id] = i.status;
      }

      final incident = allIncidents.firstWhere((i) => i.status == statusResolved);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Tolak'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Tolak'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Perbaikan belum selesai');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Tolak Insiden'));
      await tester.pumpAndSettle();

      final updated = allIncidents.firstWhere((i) => i.id == incident.id);
      expect(updated.status, statusAssigned);
      expect(find.text('Insiden dikembalikan ke Assigned.'), findsOneWidget);

      for (final i in allIncidents) {
        if (originalStatus.containsKey(i.id)) {
          allIncidents[allIncidents.indexWhere((x) => x.id == i.id)] =
              i.copyWith(status: originalStatus[i.id]!);
        }
      }
    });
  });

  group('Update Status button', () {
    testWidgets('is visible for admin on non-terminal incidents', (tester) async {
      final incident = allIncidents.firstWhere((i) => i.status == statusOpen);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
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
      final incident = allIncidents.firstWhere((i) => i.status == statusClosed);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Update Status'), findsNothing);
    });

    testWidgets('opens status update sheet with next statuses', (tester) async {
      final originalStatus = <String, String>{};
      for (final i in allIncidents) {
        originalStatus[i.id] = i.status;
      }
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final incident = allIncidents.firstWhere((i) => i.status == statusOpen);
      await tester.pumpWidget(MaterialApp(
        home: IncidentDetailScreen(
          incident: incident,
          showAdminActions: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Update Status'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Status'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(OutlinedButton, 'Assigned'), findsOneWidget);

      for (final i in allIncidents) {
        if (originalStatus.containsKey(i.id)) {
          allIncidents[allIncidents.indexWhere((x) => x.id == i.id)] =
              i.copyWith(status: originalStatus[i.id]!);
        }
      }
    });
  });
}
