import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civic_campus/screens/super_admin/super_admin_home_screen.dart';
import '../test_helper.dart';

/// Pumps until the widget tree settles enough for provider-driven loads to complete.
/// Mock APIs return synchronously, so 3 pumps are sufficient:
/// 1. build tree → postFrameCallback scheduled
/// 2. postFrameCallback fires → _load() → mock API returns → setState
/// 3. setState rebuilds with loaded content
Future<void> pumpUntilLoaded(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await initTestEnv();
  });

  group('Super Admin Home Screen', () {
    Widget buildApp() {
      return wrapWithProviders(
        child: const MaterialApp(
          home: SuperAdminHomeScreen(),
        ),
      );
    }

    testWidgets('Dashboard tab loads with greeting and stats',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await pumpUntilLoaded(tester);

      expect(find.text('Selamat Datang,'), findsOneWidget);
      expect(find.text('Admin Utama'), findsOneWidget);
      expect(find.text('Pengguna Terdaftar'), findsOneWidget);
      expect(find.text('Siswa'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('bottom navigation switches between tabs',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await pumpUntilLoaded(tester);

      await tester.tap(find.byIcon(Icons.people_outline));
      await pumpUntilLoaded(tester);
      expect(find.text('Kelola Pengguna'), findsAtLeastNWidgets(1));

      await tester.tap(find.byIcon(Icons.list_alt_outlined));
      await pumpUntilLoaded(tester);
      expect(find.text('Daftar Insiden'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await pumpUntilLoaded(tester);
      expect(find.text('Konfigurasi Sistem'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.dashboard_outlined));
      await pumpUntilLoaded(tester);
      expect(find.text('Selamat Datang,'), findsOneWidget);
    });

    testWidgets('Users tab shows empty state when no users',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await pumpUntilLoaded(tester);

      await tester.tap(find.byIcon(Icons.people_outline));
      await pumpUntilLoaded(tester);

      expect(find.text('Kelola Pengguna'), findsAtLeastNWidgets(1));
      expect(find.text('Tidak ada pengguna.'), findsOneWidget);
    });

    testWidgets('Users tab add button opens bottom sheet',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await pumpUntilLoaded(tester);

      await tester.tap(find.byIcon(Icons.people_outline));
      await pumpUntilLoaded(tester);

      await tester.tap(
          find.widgetWithText(TextButton, 'Tambah'));
      await pumpUntilLoaded(tester);

      expect(find.text('Tambah Pengguna'), findsOneWidget);
    });

    testWidgets('Insiden tab shows empty state with no incidents',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await pumpUntilLoaded(tester);

      await tester.tap(find.byIcon(Icons.list_alt_outlined));
      await pumpUntilLoaded(tester);

      expect(find.text('Daftar Insiden'), findsOneWidget);
      expect(find.text('Tidak ada insiden.'), findsOneWidget);
    });

    testWidgets('Insiden tab filters by status (no incidents)',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await pumpUntilLoaded(tester);

      await tester.tap(find.byIcon(Icons.list_alt_outlined));
      await pumpUntilLoaded(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Menunggu Penanganan'));
      await pumpUntilLoaded(tester);

      expect(find.text('Tidak ada insiden.'), findsOneWidget);
    });

    testWidgets(
        'System Config tab shows app info and role sections',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await pumpUntilLoaded(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await pumpUntilLoaded(tester);

      expect(find.text('Konfigurasi Sistem'), findsOneWidget);
      expect(find.text('Informasi Aplikasi'), findsOneWidget);
      expect(find.text('Role & Hak Akses'), findsOneWidget);
    });
  });
}
