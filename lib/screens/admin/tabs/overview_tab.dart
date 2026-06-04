import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/widgets/state_views.dart';

class AdminOverviewTab extends StatefulWidget {
  final void Function(String statusFilter) onQuickAction;

  const AdminOverviewTab({super.key, required this.onQuickAction});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  bool _isLoading = true;
  bool _hasError = false;

  int _highPriorityCount = 0;
  int _openCount = 0;
  int _overdueCount = 0;
  int _activeStaffCount = 0;

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
      final provider = context.read<IncidentProvider>();
      await provider.loadAll();
      if (!mounted) return;
      final items = provider.incidents;
      int high = 0, open = 0, overdue = 0;
      final staff = <String>{};
      for (final i in items) {
        final status = i['status'] as String? ?? '';
        final assignedTo = i['assigned_to_name'] as String? ??
            i['assigned_to'] as String?;
        final priority = i['priority_label'] as String? ?? 'Sedang';
        final createdAtStr = i['created_at'] as String? ?? '';
        final createdAt =
            DateTime.tryParse(createdAtStr) ?? DateTime.now();
        if (status == statusOpen && assignedTo == null) open++;
        final isOverdue = !{statusResolved, statusClosed}.contains(status) &&
            DateTime.now().difference(createdAt) >
                const Duration(hours: 24);
        if (isOverdue) overdue++;
        if (priority == 'Tinggi' && status != statusClosed) high++;
        if (assignedTo != null &&
            status != statusResolved &&
            status != statusClosed) {
          staff.add(assignedTo);
        }
      }
      setState(() {
        _highPriorityCount = high;
        _openCount = open;
        _overdueCount = overdue;
        _activeStaffCount = staff.length;
      });
    } catch (e) {
      debugPrint('AdminOverviewTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();
    if (_hasError) return ErrorView(message: 'Gagal memuat overview.', onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(height: 8),
            const Text('Ringkasan operasional fasilitas kampus.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5)),
            const SizedBox(height: 28),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _MetricCard(
                    label: 'Butuh Penanganan', value: '$_highPriorityCount',
                    valueColor: const Color(0xFFEF4444),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(
                    label: 'Belum Ditugaskan', value: '$_openCount',
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
                    label: 'Terlambat', value: '$_overdueCount',
                    valueColor: const Color(0xFFFBBF24),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(
                    label: 'Beban Staff Aktif', value: '$_activeStaffCount',
                    valueColor: const Color(0xFF6B7280),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Aksi Cepat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _QuickActionCard(
                  label: 'Assign', icon: Icons.person_add_alt_1, color: const Color(0xFF3B82F6),
                  onTap: () => widget.onQuickAction(statusOpen),
                )),
                const SizedBox(width: 10),
                Expanded(child: _QuickActionCard(
                  label: 'Review', icon: Icons.rate_review_outlined, color: const Color(0xFFF97316),
                  onTap: () => widget.onQuickAction(statusInProgress),
                )),
              ],
            ),
            const SizedBox(height: 10),
            _QuickActionCard(
              label: 'Tutup Insiden', icon: Icons.check_circle_outline, color: const Color(0xFF10B981),
              onTap: () => widget.onQuickAction(statusResolved),
            ),
          ],
        ),
      ),
    );
  }
}

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
