import 'package:flutter/material.dart';

import '../../../data/models/incident.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/incident_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../widgets/state_views.dart';

class SuperAdminDashboardTab extends StatefulWidget {
  const SuperAdminDashboardTab({super.key});

  @override
  State<SuperAdminDashboardTab> createState() => _SuperAdminDashboardTabState();
}

class _SuperAdminDashboardTabState extends State<SuperAdminDashboardTab> {
  final _incidentRepo = IncidentRepository();
  final _userRepo = UserRepository();
  bool _isLoading = true;
  bool _hasError = false;

  int _studentCount = 0;
  int _staffCount = 0;
  int _facilityAdminCount = 0;
  int _totalUsers = 0;

  int _totalIncidents = 0;
  int _openCount = 0;
  int _assignedCount = 0;
  int _inProgressCount = 0;
  int _resolvedCount = 0;
  int _closedCount = 0;
  int _highPriorityCount = 0;
  int _unassignedCount = 0;
  int _overdueCount = 0;
  int _activeStaffCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    try {
      final results = await Future.wait([
        _userRepo.getAllUsers(),
        _incidentRepo.getAll(),
      ]);
      if (!mounted) return;
      final users = results[0] as List<User>;
      final incidents = results[1] as List<Incident>;

      setState(() {
        _studentCount = users.where((u) => u.role == 'Student').length;
        _staffCount = users.where((u) => u.role == 'Staff').length;
        _facilityAdminCount = users.where(
          (u) => u.role == 'Facility Admin' || u.role == 'Super Admin',
        ).length;
        _totalUsers = users.length;

        _totalIncidents = incidents.length;
        _openCount = incidents.where((i) => i.status == statusOpen).length;
        _assignedCount = incidents.where((i) => i.status == statusAssigned).length;
        _inProgressCount = incidents.where((i) => i.status == statusInProgress).length;
        _resolvedCount = incidents.where((i) => i.status == statusResolved).length;
        _closedCount = incidents.where((i) => i.status == statusClosed).length;
        _highPriorityCount = incidents.where((i) => i.priority == 'Tinggi' && i.status != statusClosed).length;
        _unassignedCount = incidents.where((i) => i.status == statusOpen && i.assignedTo == null).length;
        _overdueCount = incidents.where((i) => i.isOverdue()).length;
        final activeStaff = <String>{};
        for (final i in incidents) {
          if (i.assignedTo != null &&
              i.status != statusResolved &&
              i.status != statusClosed) {
            activeStaff.add(i.assignedTo!);
          }
        }
        _activeStaffCount = activeStaff.length;
      });
    } catch (e) {
      debugPrint('SuperAdminDashboardTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();
    if (_hasError) return ErrorView(message: 'Gagal memuat dashboard.', onRetry: _load);

    final resolvedPct = _totalIncidents > 0
        ? ((_resolvedCount + _closedCount) / _totalIncidents * 100).round()
        : 0;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat Datang,',
                          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.2)),
                      const SizedBox(height: 4),
                      const Text('Admin Utama',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827), height: 1.1)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Ringkasan sistem CIVIC Campus.',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 28),

            const Text('Pengguna Terdaftar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _MiniCard(value: '$_studentCount', label: 'Siswa', color: const Color(0xFF3B82F6), icon: Icons.school)),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniCard(value: '$_staffCount', label: 'Staff', color: const Color(0xFF10B981), icon: Icons.build)),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniCard(value: '$_facilityAdminCount', label: 'Admin', color: const Color(0xFF8B5CF6), icon: Icons.shield)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text('$_totalUsers total pengguna terdaftar',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                const Text('Insiden',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$resolvedPct% selesai',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _StatusBar(label: 'Terbuka', count: _openCount, total: _totalIncidents, color: const Color(0xFF3B82F6)),
            const SizedBox(height: 10),
            _StatusBar(label: 'Ditugaskan', count: _assignedCount, total: _totalIncidents, color: const Color(0xFFF97316)),
            const SizedBox(height: 10),
            _StatusBar(label: 'Diproses', count: _inProgressCount, total: _totalIncidents, color: const Color(0xFFFBBF24)),
            const SizedBox(height: 10),
            _StatusBar(label: 'Selesai', count: _resolvedCount, total: _totalIncidents, color: const Color(0xFF10B981)),
            const SizedBox(height: 10),
            _StatusBar(label: 'Ditutup', count: _closedCount, total: _totalIncidents, color: const Color(0xFF6B7280)),

            const SizedBox(height: 28),

            const Text('Ringkasan Cepat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _MiniCard(value: '$_highPriorityCount', label: 'Prioritas Tinggi', color: const Color(0xFFEF4444), icon: Icons.warning)),
                const SizedBox(width: 10),
                Expanded(child: _MiniCard(value: '$_unassignedCount', label: 'Belum Ditugaskan', color: const Color(0xFFF97316), icon: Icons.person_add_alt_1)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _MiniCard(value: '$_overdueCount', label: 'Terlambat', color: const Color(0xFFEF4444), icon: Icons.access_time)),
                const SizedBox(width: 10),
                Expanded(child: _MiniCard(value: '$_activeStaffCount', label: 'Staff Aktif', color: const Color(0xFF3B82F6), icon: Icons.engineering)),
              ],
            ),

            const SizedBox(height: 28),

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
                        const Text('Total Insiden',
                            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                        const SizedBox(height: 4),
                        Text('$_totalIncidents',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF111827), height: 1.1)),
                      ],
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.assignment, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _MiniCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color, height: 1.1)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StatusBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.02), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text('$count',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}
