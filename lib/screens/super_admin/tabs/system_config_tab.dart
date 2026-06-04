import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/constants/app_constants.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/data/providers/user_provider.dart';
import 'package:civic_campus/widgets/state_views.dart';

class SuperAdminSystemConfigTab extends StatefulWidget {
  const SuperAdminSystemConfigTab({super.key});

  @override
  State<SuperAdminSystemConfigTab> createState() => _SuperAdminSystemConfigTabState();
}

class _SuperAdminSystemConfigTabState extends State<SuperAdminSystemConfigTab> {
  int _totalIncidents = 0;
  int _staffCount = 0;
  int _staffTasks = 0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    try {
      final incProvider = context.read<IncidentProvider>();
      final userProvider = context.read<UserProvider>();
      await Future.wait([
        incProvider.loadAll(),
        userProvider.load(),
      ]);
      if (!mounted) return;
      final incidents = incProvider.incidents;
      final users = userProvider.users;
      final staff = users.where((u) => u['role'] == 'Maintenance Staff').toList();
      final staffNames = staff.map((s) => s['name'] as String).toSet();
      final staffTasks = incidents
          .where((i) {
            final assignedTo = i['assigned_to_name'] as String? ??
                i['assigned_to'] as String?;
            return assignedTo != null && staffNames.contains(assignedTo);
          })
          .length;
      setState(() {
        _totalIncidents = incidents.length;
        _staffCount = staff.length;
        _staffTasks = staffTasks;
      });
    } catch (e) {
      debugPrint('SuperAdminSystemConfigTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();
    if (_hasError) return ErrorView(message: 'Gagal memuat konfigurasi.', onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const Text('Konfigurasi Sistem',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 8),
          const Text('Informasi sistem dan konfigurasi global.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5)),
          const SizedBox(height: 28),

          _SectionTitle('Informasi Aplikasi'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                _InfoRow('Nama Aplikasi', appName),
                const Divider(height: 24),
                _InfoRow('Versi', appVersion),
                const Divider(height: 24),
                _InfoRow('Hak Cipta', appCopyright),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _SectionTitle('Role & Hak Akses'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                _RoleRow(role: 'Student', description: 'Melapor dan memantau insiden', color: const Color(0xFF3B82F6)),
                const Divider(height: 24),
                _RoleRow(role: 'Staff', description: 'Mengerjakan tugas yang ditugaskan', color: const Color(0xFF10B981)),
                const Divider(height: 24),
                _RoleRow(role: 'Facility Admin', description: 'Kelola insiden, staff, dan master data', color: const Color(0xFFF97316)),
                const Divider(height: 24),
                _RoleRow(role: 'Super Admin', description: 'Kelola pengguna dan konfigurasi sistem', color: const Color(0xFF8B5CF6)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _SectionTitle('Beban Kerja Staff'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Staff Aktif', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 4),
                      Text('$_staffCount',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF111827), height: 1.1)),
                    ],
                  ),
                ),
                Container(width: 1, height: 60, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Tugas Aktif', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 4),
                      Text('$_staffTasks',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFF97316), height: 1.1)),
                    ],
                  ),
                ),
                Container(width: 1, height: 60, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Insiden', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 4),
                      Text('$_totalIncidents',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6), height: 1.1)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _SectionTitle('Riwayat Audit'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AuditEntry(action: 'INS-001 dibuat', user: 'Budi Santoso', time: '10 menit lalu'),
                const Divider(height: 20),
                _AuditEntry(action: 'INS-002 ditugaskan ke Budi Teknisi', user: 'Admin Utama', time: '1 jam lalu'),
                const Divider(height: 20),
                _AuditEntry(action: 'INS-003 status diubah ke Diproses', user: 'Budi Teknisi', time: '2 jam lalu'),
                const Divider(height: 20),
                _AuditEntry(action: 'INS-001 ditutup', user: 'Admin Utama', time: '3 jam lalu'),
                const Divider(height: 20),
                _AuditEntry(action: 'Pengguna baru: Siti Nurlela ditambahkan', user: 'Admin Utama', time: '5 jam lalu'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827)));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
      ],
    );
  }
}

class _RoleRow extends StatelessWidget {
  final String role;
  final String description;
  final Color color;

  const _RoleRow({
    required this.role,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(role[0],
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuditEntry extends StatelessWidget {
  final String action;
  final String user;
  final String time;

  const _AuditEntry({
    required this.action,
    required this.user,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(color: Color(0xFFD1D5DB), shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
              const SizedBox(height: 2),
              Text('$user \u2022 $time', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ],
    );
  }
}
