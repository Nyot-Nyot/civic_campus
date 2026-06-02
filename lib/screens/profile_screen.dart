import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/models/user.dart';
import '../data/dummy_data.dart';
import '../data/repositories/incident_repository.dart';
import '../widgets/logout_sheet.dart';
import '../widgets/state_views.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;

  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return _ProfileBody(user: user ?? currentUser);
  }
}

class _ProfileBody extends StatefulWidget {
  final User user;

  const _ProfileBody({required this.user});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  bool _notificationsEnabled = true;
  final _incidentRepo = IncidentRepository();

  static const _roleStyles = {
    'Student': (Color(0xFFEFF6FF), Color(0xFF3B82F6)),
    'Staff': (Color(0xFFD1FAE5), Color(0xFF10B981)),
    'Facility Admin': (Color(0xFFFFEDD5), Color(0xFFF97316)),
    'Super Admin': (Color(0xFFF3E8FF), Color(0xFF8B5CF6)),
  };

  static (Color bg, Color fg) _roleStyle(String role) =>
      _roleStyles[role] ?? (const Color(0xFFF3F4F6), const Color(0xFF6B7280));

  int _totalIncidents = 0;
  int _activeIncidents = 0;
  int _completedIncidents = 0;
  int _inProgressTasks = 0;
  int _overdueTasks = 0;
  bool _isLoadingStats = true;
  bool get _isStaff => widget.user.role == 'Staff';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (_isStaff) {
      final tasks = await _incidentRepo.getAssignedTo(widget.user.name);
      if (!mounted) return;
      setState(() {
        _totalIncidents = tasks.length;
        _inProgressTasks = tasks.where((t) => t.status == statusInProgress).length;
        _overdueTasks = tasks.where((t) => t.isOverdue()).length;
        _isLoadingStats = false;
      });
    } else {
      final results = await Future.wait([
        _incidentRepo.getAll(),
        _incidentRepo.getActive(),
        _incidentRepo.getCompleted(),
      ]);
      if (!mounted) return;
      setState(() {
        _totalIncidents = (results[0] as List).length;
        _activeIncidents = (results[1] as List).length;
        _completedIncidents = (results[2] as List).length;
        _isLoadingStats = false;
      });
    }
  }

  void _confirmLogout(BuildContext context) {
    LogoutSheet.show(
      context,
      () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelola detail akun dan lihat informasi peran Anda.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildMenuSection(),
          const SizedBox(height: 24),
          _buildDangerSection(context),
        ],
      ),
    ),
    );
  }

  Widget _buildProfileHeader() {
    final user = widget.user;
    final style = _roleStyle(user.role);
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: style.$1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        user.role,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: style.$2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    if (_isLoadingStats) {
      return const SizedBox(height: 120, child: LoadingView());
    }

    if (_isStaff) {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
                'Ditugaskan', _totalIncidents.toString(), Icons.assignment_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
                'Dikerjakan', _inProgressTasks.toString(), Icons.engineering_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
                'Terlambat', _overdueTasks.toString(), Icons.warning_amber_outlined),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              'Total', _totalIncidents.toString(), Icons.description_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              _buildStatCard('Aktif', _activeIncidents.toString(), Icons.trending_up),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
              'Selesai', _completedIncidents.toString(), Icons.check_circle_outline),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF3B82F6)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
              activeThumbColor: const Color(0xFF111827),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.language_outlined,
            title: 'Bahasa',
            subtitle: 'Indonesia',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengaturan bahasa akan hadir.')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'v$appVersion',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: appName,
                applicationVersion: appVersion,
                applicationLegalese: appCopyright,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 22, color: const Color(0xFF6B7280)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else
                const Icon(Icons.chevron_right,
                    size: 20, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: const Color(0xFFF3F4F6)),
    );
  }

  Widget _buildDangerSection(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _confirmLogout(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.logout, size: 22, color: Color(0xFFEF4444)),
                const SizedBox(width: 14),
                const Text(
                  'Keluar Akun',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    size: 20, color: Color(0xFFD1D5DB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
