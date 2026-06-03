import 'package:flutter/material.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/repositories/incident_repository.dart';
import 'package:civic_campus/screens/staff/widgets/staff_task_card.dart';
import 'package:civic_campus/widgets/state_views.dart';
import 'package:civic_campus/screens/shared/incident/detail/incident_detail_screen.dart';

class StaffMyTasksTab extends StatefulWidget {
  final String staffName;

  const StaffMyTasksTab({super.key, required this.staffName});

  @override
  State<StaffMyTasksTab> createState() => _StaffMyTasksTabState();
}

class _StaffMyTasksTabState extends State<StaffMyTasksTab> {
  final _repo = IncidentRepository();
  List<Incident> _tasks = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _activeFilter = 'Semua';

  final _filters = ['Semua', statusOpen, statusAssigned, statusInProgress, statusResolved];

  List<Incident> get _filteredTasks {
    final sorted = List<Incident>.from(_tasks)
      ..sort((a, b) {
        const order = ['Tinggi', 'Sedang', 'Rendah'];
        return order.indexOf(a.priority).compareTo(order.indexOf(b.priority));
      });
    if (_activeFilter == 'Semua') return sorted;
    return sorted.where((t) => t.status == _activeFilter).toList();
  }

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
      final items = await _repo.getAssignedTo(widget.staffName);
      if (!mounted) return;
      setState(() {
        _tasks = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('StaffMyTasksTab._load error: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _openDetail(Incident incident) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IncidentDetailScreen(
          incident: incident,
          showStaffActions: true,
        ),
      ),
    );
    if (!mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Halo, ${widget.staffName}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Berikut tugas yang ditugaskan kepada Anda.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tugas Saya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = _filters[index];
                      final selected = _activeFilter == f;
                      return ChoiceChip(
                        label: Text(f),
                        selected: selected,
                        onSelected: (_) => setState(() => _activeFilter = f),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : const Color(0xFF6B7280),
                        ),
                        backgroundColor: const Color(0xFFF3F4F6),
                        selectedColor: const Color(0xFF111827),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: _isLoading
                ? const SliverLoadingView()
                : _hasError
                    ? SliverErrorView(message: 'Gagal memuat tugas.', onRetry: _load)
                    : tasks.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Column(
                                children: [
                                  const Icon(Icons.task_alt, size: 56, color: Color(0xFFD1D5DB)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Tidak ada tugas saat ini.',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tugas baru akan muncul di sini\nsetelah admin menugaskan Anda.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final item = tasks[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: index == tasks.length - 1 ? 0 : 14),
                                child: StaffTaskCard(
                                  incident: item,
                                  onTap: () => _openDetail(item),
                                ),
                              );
                            }, childCount: tasks.length),
                          ),
          ),
        ],
      ),
    );
  }
}
