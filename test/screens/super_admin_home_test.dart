import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civic_campus/screens/super_admin_home_screen.dart';

void main() {
  group('Super Admin Home Screen', () {
    Widget buildApp() {
      return const MaterialApp(
        home: SuperAdminHomeScreen(),
      );
    }

    testWidgets('Dashboard tab loads with greeting and stats',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();
      expect(find.text('Kelola Pengguna'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.list_alt_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Daftar Insiden'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Konfigurasi Sistem'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.dashboard_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Selamat Datang,'), findsOneWidget);
    });

    testWidgets('Users tab shows list of users', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();

      expect(find.text('Andi Mahasiswa'), findsOneWidget);
      expect(find.text('Budi Teknisi'), findsOneWidget);
      expect(find.text('Admin Utama'), findsOneWidget);
    });

    testWidgets('Users tab add button opens bottom sheet',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(TextButton, 'Tambah'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Pengguna'), findsOneWidget);
    });

    testWidgets('Insiden tab shows incident list', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list_alt_outlined));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('AC ruang kuliah tidak dingin'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('AC ruang kuliah tidak dingin'),
          findsOneWidget);
    });

    testWidgets('Insiden tab filters by status', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list_alt_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Menunggu Penanganan'));
      await tester.pumpAndSettle();

      expect(find.text('Lampu koridor mati'), findsOneWidget);
    });

    testWidgets(
        'System Config tab shows app info and role sections',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Konfigurasi Sistem'), findsOneWidget);
      expect(find.text('Informasi Aplikasi'), findsOneWidget);
      expect(find.text('Role & Hak Akses'), findsOneWidget);
    });
  });
}
