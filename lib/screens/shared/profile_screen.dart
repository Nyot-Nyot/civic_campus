import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/models/user.dart';
import 'package:civic_campus/data/constants/app_constants.dart';
import 'package:civic_campus/data/providers/auth_provider.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/widgets/logout_sheet.dart';
import 'package:civic_campus/widgets/state_views.dart';
import 'package:civic_campus/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Object? user;

  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    User? resolvedUser;
    if (user is User) {
      resolvedUser = user as User;
    } else if (user is Map<String, dynamic>) {
      resolvedUser = User.fromJson(user as Map<String, dynamic>);
    }
    return _ProfileBody(user: resolvedUser);
  }
}

class _ProfileBody extends StatefulWidget {
  final User? user;

  const _ProfileBody({this.user});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  bool _notificationsEnabled = true;

  static const _roleStyles = {
    'Student': (Color(0xFFEFF6FF), Color(0xFF3B82F6)),
    'Maintenance Staff': (Color(0xFFD1FAE5), Color(0xFF10B981)),
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

  User get _user {
    if (widget.user != null) return widget.user!;
    final profile = context.read<AuthProvider>().profile;
    if (profile != null) return User.fromJson(profile);
    return const User(name: 'User', role: 'Student', email: '');
  }

  bool get _isStaff => _user.role == 'Maintenance Staff';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  Future<void> _loadStats() async {
    final incProvider = context.read<IncidentProvider>();
    final auth = context.read<AuthProvider>();
    if (_isStaff) {
      await incProvider.loadAll(assignedTo: auth.userId);
      if (!mounted) return;
      final tasks = incProvider.incidents;
      setState(() {
        _totalIncidents = tasks.length;
        _inProgressTasks = tasks.where((t) => t['status'] == 'In Progress').length;
        _overdueTasks = tasks.where((t) {
          final status = t['status'] as String? ?? '';
          if ({'Resolved', 'Closed'}.contains(status)) return false;
          final createdAtStr = t['created_at'] as String? ?? '';
          final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
          return DateTime.now().difference(createdAt) > const Duration(hours: 24);
        }).length;
        _isLoadingStats = false;
      });
    } else {
      await incProvider.loadAll();
      final items = incProvider.incidents;
      final activeCount = items.where((i) {
        final status = i['status'] as String? ?? '';
        return status != 'Resolved' && status != 'Closed';
      }).length;
      final completedCount = items.where((i) {
        final status = i['status'] as String? ?? '';
        return status == 'Resolved' || status == 'Closed';
      }).length;
      if (!mounted) return;
      setState(() {
        _totalIncidents = items.length;
        _activeIncidents = activeCount;
        _completedIncidents = completedCount;
        _isLoadingStats = false;
      });
    }
  }

  void _confirmLogout(BuildContext context) {
    LogoutSheet.show(
      context,
      () {
        context.read<AuthProvider>().signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
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
    final user = _user;
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
