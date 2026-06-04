import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/status_update_sheet.dart';
import '../test_helper.dart';

Widget _buildSheet(Incident incident, List<String> statuses) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showModalBottomSheet(
            context: ctx,
            builder: (_) => wrapWithProviders(
              child: StatusUpdateSheet(
                incident: incident,
                nextStatuses: statuses,
                onUpdated: (_) {},
              ),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

Future<void> openSheet(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> scrollToKirim(WidgetTester tester) async {
  await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Kirim'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initTestEnv();
  });

  final incident = Incident(
    id: 'test-id',
    title: 'AC Rusak',
    location: 'A101',
    category: 'AC',
    status: 'Assigned',
    timeAgo: '2 jam lalu',
    createdAt: DateTime.now(),
  );

  group('StatusUpdateSheet non-resolve', () {
    final statuses = ['Assigned', 'In Progress'];

    testWidgets('shows status buttons and Kirim disabled initially', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSheet(incident, statuses));
      await openSheet(tester);

      expect(find.text('Update Status'), findsOneWidget);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Tambah Foto'), findsOneWidget);

      final kirim = find.widgetWithText(ElevatedButton, 'Kirim');
      expect(kirim, findsOneWidget);
      final btn = tester.widget<ElevatedButton>(kirim);
      expect(btn.onPressed, isNull,
          reason: 'Kirim should be disabled when no status selected');
    });

    testWidgets('selecting a status enables Kirim button', (tester) async {
      await tester.pumpWidget(_buildSheet(incident, statuses));
      await openSheet(tester);

      await tester.tap(find.text('In Progress'));
      await tester.pumpAndSettle();

      await scrollToKirim(tester);
      final kirim = find.widgetWithText(ElevatedButton, 'Kirim');
      final btn = tester.widget<ElevatedButton>(kirim);
      expect(btn.onPressed, isNotNull,
          reason: 'Kirim should be enabled after selecting a status');
    });

    testWidgets('tapping Kirim triggers update and closes sheet', (tester) async {
      await tester.pumpWidget(_buildSheet(incident, statuses));
      await openSheet(tester);

      await tester.tap(find.text('In Progress'));
      await tester.pumpAndSettle();

      await scrollToKirim(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Kirim'));
      await tester.pumpAndSettle();

      // Sheet is dismissed after success; UpdateStatus text no longer visible
      expect(find.text('Update Status'), findsNothing);
    });

    testWidgets('tapping Tambah Foto opens PhotoPickerSheet', (tester) async {
      await tester.pumpWidget(_buildSheet(incident, statuses));
      await openSheet(tester);

      await tester.tap(find.text('Tambah Foto'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Bukti Foto'), findsOneWidget);
      expect(find.text('Ambil Foto'), findsOneWidget);
      expect(find.text('Pilih dari Galeri'), findsOneWidget);
    });
  });

  group('StatusUpdateSheet resolve mode', () {
    final statuses = [statusResolved];

    testWidgets('Kirim is disabled when note is empty for resolve', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSheet(incident, statuses));
      await openSheet(tester);

      await tester.tap(find.text(statusResolved));
      await tester.pumpAndSettle();

      await scrollToKirim(tester);
      final kirim = find.widgetWithText(ElevatedButton, 'Kirim');
      final btn = tester.widget<ElevatedButton>(kirim);
      expect(btn.onPressed, isNull,
          reason: 'Kirim should be disabled for resolve when note is empty');
    });

    testWidgets('Kirim is enabled when note is filled for resolve', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSheet(incident, statuses));
      await openSheet(tester);

      await tester.tap(find.text(statusResolved));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Perbaikan selesai, AC berfungsi normal.',
      );
      await tester.pumpAndSettle();

      await scrollToKirim(tester);
      final kirim = find.widgetWithText(ElevatedButton, 'Kirim');
      final btn = tester.widget<ElevatedButton>(kirim);
      expect(btn.onPressed, isNotNull,
          reason: 'Kirim should be enabled for resolve when note is filled');
    });

    testWidgets('shows hint text for resolve', (tester) async {
      await tester.pumpWidget(_buildSheet(incident, statuses));
      await openSheet(tester);

      expect(find.text('Jelaskan hasil perbaikan... (wajib)'), findsOneWidget);
    });
  });

  group('StatusUpdateSheet photos', () {
    final statuses = ['In Progress'];

    testWidgets('Tambah Foto opens PhotoPickerSheet', (tester) async {
      await tester.pumpWidget(_buildSheet(incident, statuses));
      await openSheet(tester);

      expect(find.text('Tambah Foto'), findsOneWidget);

      await tester.tap(find.text('Tambah Foto'));
      await tester.pumpAndSettle();
      expect(find.text('Ambil Foto'), findsOneWidget);
    });
  });
}
