import 'package:flutter/material.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/repositories/incident_repository.dart';
import 'package:civic_campus/widgets/state_views.dart';

class AdminStaffWorkloadTab extends StatefulWidget {
  const AdminStaffWorkloadTab({super.key});

  @override
  State<AdminStaffWorkloadTab> createState() => _AdminStaffWorkloadTabState();
}

class _AdminStaffWorkloadTabState extends State<AdminStaffWorkloadTab> {
  final _repo = IncidentRepository();
  bool _isLoading = true;
  bool _hasError = false;
  List<_StaffLoad> _staffLoads = [];

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
      final items = await _repo.getAll();
      if (!mounted) return;
      final map = <String, _StaffLoad>{};
      for (final i in items) {
        if (i.assignedTo == null) continue;
        final staff = map.putIfAbsent(
          i.assignedTo!,
          () => _StaffLoad(name: i.assignedTo!),
        );
        staff.total++;
        if (i.status == statusAssigned || i.status == statusInProgress) {
          staff.active++;
        }
        if (i.status == statusResolved) staff.resolved++;
        if (i.isOverdue()) staff.overdue++;
      }
      final sorted = map.values.toList()
        ..sort((a, b) => b.active.compareTo(a.active));
      if (!mounted) return;
      setState(() => _staffLoads = sorted);
    } catch (e) {
      debugPrint('AdminStaffWorkloadTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();
    if (_hasError) return ErrorView(message: 'Gagal memuat beban kerja.', onRetry: _load);
    if (_staffLoads.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.engineering_outlined, size: 56, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16),
            Text(
              'Belum ada staff yang ditugaskan.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            ),
          ],
        ),
      );
    }

    final maxActive = _staffLoads
        .fold(0, (int p, s) => s.active > p ? s.active : p);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const Text(
            'Beban Kerja Staff',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ringkasan tugas aktif per teknisi.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 28),
          ...List.generate(_staffLoads.length, (index) {
            final s = _staffLoads[index];
            final barRatio = maxActive > 0 ? s.active / maxActive : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          children: [
                            TextSpan(text: '${s.active} aktif',
                                style: const TextStyle(color: Color(0xFF3B82F6))),
                            const TextSpan(text: ' · '),
                            TextSpan(text: '${s.resolved} selesai',
                                style: const TextStyle(color: Color(0xFF10B981))),
                            if (s.overdue > 0) ...[
                              const TextSpan(text: ' · '),
                              TextSpan(text: '${s.overdue} terlambat',
                                  style: const TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 20,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 20,
                                color: const Color(0xFFF3F4F6),
                              ),
                              FractionallySizedBox(
                                widthFactor: barRatio.clamp(0.01, 1.0),
                                heightFactor: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: s.overdue > 0
                                        ? const LinearGradient(
                                            colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                                          )
                                        : const LinearGradient(
                                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StaffLoad {
  final String name;
  int total = 0;
  int active = 0;
  int resolved = 0;
  int overdue = 0;
  _StaffLoad({required this.name});
}
