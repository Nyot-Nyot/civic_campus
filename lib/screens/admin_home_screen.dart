import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/repositories/incident_repository.dart';

class AdminHomeScreen extends StatefulWidget {
  static const routeName = '/admin-home';

  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  static const _icons = <IconData>[
    Icons.dashboard_outlined,
    Icons.list_alt_outlined,
    Icons.bar_chart_outlined,
    Icons.people_outline,
  ];

  static const _selectedIcons = <IconData>[
    Icons.dashboard,
    Icons.list_alt,
    Icons.bar_chart,
    Icons.people,
  ];

  static const _labels = [
    'Overview',
    'Daftar Insiden',
    'Beban Kerja Staff',
    'Pengguna',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody(context)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(42),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.18),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_icons.length, (index) {
                final selected = _selectedIndex == index;
                final icon = selected
                    ? _selectedIcons[index]
                    : _icons[index];
                return Expanded(
                  child: Tooltip(
                    message: _labels[index],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(34),
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Semantics(
                          label: _labels[index],
                          button: true,
                          selected: selected,
                          child: Center(
                            child: Container(
                              width: selected ? 60 : 44,
                              height: selected ? 60 : 44,
                              decoration: selected
                                  ? const BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle,
                                    )
                                  : null,
                              child: Icon(
                                icon,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF9CA3AF),
                                size: selected ? 28 : 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0: return const _OverviewTab();
      case 1: return _placeholderTab('Daftar Insiden', Icons.list_alt_outlined);
      case 2: return _placeholderTab('Beban Kerja Staff', Icons.bar_chart_outlined);
      case 3: return _placeholderTab('Pengguna', Icons.people_outline);
      default: return const SizedBox.shrink();
    }
  }

  Widget _placeholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Segera hadir',
            style: TextStyle(fontSize: 14, color: Color(0xFFD1D5DB)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 0: Overview Dashboard
// ---------------------------------------------------------------------------

class _OverviewTab extends StatefulWidget {
  const _OverviewTab();

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  final _repo = IncidentRepository();
  bool _isLoading = true;

  int _highPriorityCount = 0;
  int _openCount = 0;
  int _overdueCount = 0;
  int _activeStaffCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _repo.getAll();
      if (!mounted) return;
      int high = 0, open = 0, overdue = 0;
      final staff = <String>{};
      for (final i in items) {
        if (i.status == statusOpen) open++;
        if (i.isOverdue()) overdue++;
        if (i.priority == 'Tinggi' && i.status != statusClosed) high++;
        if (i.assignedTo != null &&
            i.status != statusResolved &&
            i.status != statusClosed) {
          staff.add(i.assignedTo!);
        }
      }
      setState(() {
        _highPriorityCount = high;
        _openCount = open;
        _overdueCount = overdue;
        _activeStaffCount = staff.length;
      });
    } catch (e) {
      debugPrint('_OverviewTab._load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ringkasan operasional fasilitas kampus.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Metric cards — 2×2 grid
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _MetricCard(
                    label: 'Butuh Penanganan',
                    value: '$_highPriorityCount',
                    valueColor: const Color(0xFFEF4444),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(
                    label: 'Belum Ditugaskan',
                    value: '$_openCount',
                    valueColor: const Color(0xFF3B82F6),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _MetricCard(
                    label: 'Terlambat',
                    value: '$_overdueCount',
                    valueColor: const Color(0xFFFBBF24),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(
                    label: 'Beban Staff Aktif',
                    value: '$_activeStaffCount',
                    valueColor: const Color(0xFF6B7280),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Quick action cards
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    label: 'Assign',
                    icon: Icons.person_add_alt_1,
                    color: const Color(0xFF3B82F6),
                    onTap: () => _showComingSoon('Assign insiden'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionCard(
                    label: 'Review',
                    icon: Icons.rate_review_outlined,
                    color: const Color(0xFFF97316),
                    onTap: () => _showComingSoon('Review insiden'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _QuickActionCard(
              label: 'Tutup Insiden',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF10B981),
              onTap: () => _showComingSoon('Tutup insiden'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — segera hadir.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metric Card — clean white card with large number + small label
// ---------------------------------------------------------------------------

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Action Card
// ---------------------------------------------------------------------------

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
