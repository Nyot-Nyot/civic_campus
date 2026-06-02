import 'package:flutter/material.dart';

import '../../../data/models/incident.dart';
import '../../../data/models/user.dart';
import '../../../data/dummy_data.dart';
import '../../../data/repositories/incident_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../widgets/admin_incident_card.dart';
import '../../../widgets/filter_dropdown.dart';
import '../../../widgets/state_views.dart';
import '../../incident_detail_screen.dart';

class AdminIncidentListTab extends StatefulWidget {
  final String initialStatusFilter;
  final String initialPriorityFilter;

  const AdminIncidentListTab({
    super.key,
    this.initialStatusFilter = 'Semua',
    this.initialPriorityFilter = 'Semua',
  });

  @override
  State<AdminIncidentListTab> createState() => _AdminIncidentListTabState();
}

class _AdminIncidentListTabState extends State<AdminIncidentListTab> {
  final _repo = IncidentRepository();
  final _userRepo = UserRepository();
  List<Incident> _incidents = [];
  List<String> _staffNames = [];
  bool _isLoading = true;
  bool _hasError = false;
  late String _activeFilter;
  late String _activePriorityFilter;
  String _searchQuery = '';
  String _staffFilter = 'Semua';

  final _filters = [
    'Semua', statusOpen, statusAssigned, statusInProgress, statusResolved, statusClosed,
  ];

  static const _priorityFilters = ['Semua', 'Tinggi', 'Sedang', 'Rendah'];

  static const _statusLabels = {
    'Semua': 'Semua',
    statusOpen: 'Menunggu Penanganan',
    statusAssigned: 'Sudah Ditugaskan',
    statusInProgress: 'Sedang Dikerjakan',
    statusResolved: 'Selesai Dikerjakan',
    statusClosed: 'Ditutup',
  };

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialStatusFilter;
    _activePriorityFilter = widget.initialPriorityFilter;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    try {
      final results = await Future.wait([
        _repo.getAll(),
        _userRepo.getAllUsers(),
      ]);
      if (!mounted) return;
      final users = results[1] as List<User>;
      setState(() {
        _incidents = results[0] as List<Incident>;
        _staffNames = users.where((u) => u.role == 'Staff').map((u) => u.name).toList();
      });
    } catch (e) {
      debugPrint('AdminIncidentListTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didUpdateWidget(AdminIncidentListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStatusFilter != oldWidget.initialStatusFilter ||
        widget.initialPriorityFilter != oldWidget.initialPriorityFilter) {
      setState(() {
        _activeFilter = widget.initialStatusFilter;
        _activePriorityFilter = widget.initialPriorityFilter;
      });
    }
  }

  List<Incident> get _filteredIncidents {
    var filtered = List<Incident>.from(_incidents);
    if (_activeFilter != 'Semua') {
      filtered = filtered.where((i) => i.status == _activeFilter).toList();
    }
    if (_activePriorityFilter != 'Semua') {
      filtered = filtered.where((i) => i.priority == _activePriorityFilter).toList();
    }
    if (_staffFilter != 'Semua') {
      filtered = filtered.where((i) => i.assignedTo == _staffFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((i) =>
        i.title.toLowerCase().contains(q) ||
        i.location.toLowerCase().contains(q) ||
        i.description.toLowerCase().contains(q)
      ).toList();
    }
    filtered.sort((a, b) {
      const rank = {'Tinggi': 0, 'Sedang': 1, 'Rendah': 2};
      final pa = rank[a.priority] ?? 999;
      final pb = rank[b.priority] ?? 999;
      if (pa != pb) return pa.compareTo(pb);
      return b.createdAt.compareTo(a.createdAt);
    });
    return filtered;
  }

  void _quickAssign(Incident item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Assign Staff',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih staff untuk "${item.title}".',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),
                ...List.generate(_staffNames.length, (idx) {
                  final name = _staffNames[idx];
                  return Padding(
                    padding: EdgeInsets.only(bottom: idx < _staffNames.length - 1 ? 10 : 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          final ok = await _repo.updateStatus(
                            item.id,
                            statusAssigned,
                            notes: 'Ditugaskan ke $name',
                          );
                          if (!mounted) return;
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Laporan tidak ditemukan.')),
                            );
                            return;
                          }
                          final updated = item.copyWith(
                            status: statusAssigned,
                            assignedTo: name,
                          );
                          final idx2 = allIncidents.indexWhere((i) => i.id == item.id);
                          if (idx2 != -1) {
                            allIncidents[idx2] = updated;
                          }
                          _load();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ditugaskan ke $name.')),
                          );
                        },
                        icon: const Icon(Icons.person_add, size: 20),
                        label: Text(name),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          foregroundColor: const Color(0xFF111827),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidents = _filteredIncidents;

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Daftar Insiden',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Semua insiden fasilitas kampus.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 42,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Cari insiden...',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        label: Text(_statusLabels[f] ?? f),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilterDropdown(
                        label: 'Prioritas',
                        value: _activePriorityFilter == 'Semua' ? null : _activePriorityFilter,
                        items: _priorityFilters,
                        icon: _activePriorityFilter == 'Semua'
                            ? null
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: priorityColors[_activePriorityFilter] ?? const Color(0xFF6B7280),
                                  shape: BoxShape.circle,
                                ),
                              ),
                        onSelected: (v) => setState(() => _activePriorityFilter = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_staffNames.isNotEmpty)
                      Expanded(
                        child: FilterDropdown(
                          label: 'Staff',
                          value: _staffFilter == 'Semua' ? null : _staffFilter,
                          items: ['Semua', ..._staffNames],
                          onSelected: (v) => setState(() => _staffFilter = v),
                        ),
                      ),
                  ],
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
                  ? SliverErrorView(message: 'Gagal memuat insiden.', onRetry: _load)
                  : incidents.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            const Icon(Icons.inbox_outlined, size: 56, color: Color(0xFFD1D5DB)),
                            const SizedBox(height: 16),
                            const Text(
                              'Tidak ada insiden.',
                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = incidents[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: index == incidents.length - 1 ? 0 : 14),
                          child: AdminIncidentCard(
                            incident: item,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IncidentDetailScreen(
                                    incident: item,
                                    showAdminActions: true,
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              _load();
                            },
                            onAssign: item.status == statusOpen
                                ? () => _quickAssign(item)
                                : null,
                          ),
                        );
                      }, childCount: incidents.length),
                    ),
          ),
        ],
      ),
    );
  }
}
