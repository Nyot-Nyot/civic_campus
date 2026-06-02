import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/models/building.dart';
import '../data/models/category.dart';
import '../data/models/user.dart';
import '../data/repositories/incident_repository.dart';
import '../data/repositories/building_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/dummy_data.dart';
import 'incident_detail_screen.dart';
import 'login_screen.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/state_views.dart';

class AdminHomeScreen extends StatefulWidget {
  static const routeName = '/admin-home';

  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  String _incidentStatusFilter = 'Semua';
  String _incidentPriorityFilter = 'Semua';

  static const _icons = <IconData>[
    Icons.dashboard_outlined,
    Icons.list_alt_outlined,
    Icons.bar_chart_outlined,
    Icons.business_outlined,
  ];

  static const _selectedIcons = <IconData>[
    Icons.dashboard,
    Icons.list_alt,
    Icons.bar_chart,
    Icons.business,
  ];

  static const _labels = [
    'Overview',
    'Daftar Insiden',
    'Beban Kerja Staff',
    'Master Data',
  ];

  void _onQuickAction(String statusFilter) {
    setState(() {
      _incidentStatusFilter = statusFilter;
      _incidentPriorityFilter = 'Semua';
      _selectedIndex = 1;
    });
  }

  void _confirmLogout(BuildContext context) {
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
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Icon(Icons.logout, size: 40, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                const Text(
                  'Keluar Akun',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apakah Anda yakin ingin keluar?',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          foregroundColor: const Color(0xFF111827),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: const Text('Keluar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildBody(context),
            Positioned(
              top: 8,
              right: 16,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _confirmLogout(context),
                    child: const Icon(Icons.logout, size: 20, color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      case 0: return _OverviewTab(onQuickAction: _onQuickAction);
      case 1: return _IncidentListTab(
        key: ValueKey('$_incidentStatusFilter$_incidentPriorityFilter'),
        initialStatusFilter: _incidentStatusFilter,
        initialPriorityFilter: _incidentPriorityFilter,
      );
      case 2: return const _StaffWorkloadTab();
      case 3: return const _MasterDataTab();
      default: return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Tab 0: Overview Dashboard
// ---------------------------------------------------------------------------

class _OverviewTab extends StatefulWidget {
  final void Function(String statusFilter) onQuickAction;

  const _OverviewTab({required this.onQuickAction});

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  final _repo = IncidentRepository();
  bool _isLoading = true;
  bool _hasError = false;

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
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    try {
      final items = await _repo.getAll();
      if (!mounted) return;
      int high = 0, open = 0, overdue = 0;
      final staff = <String>{};
      for (final i in items) {
        if (i.status == statusOpen && i.assignedTo == null) open++;
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

            // Metric cards — 2×2 grid
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

            // Quick action cards
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
// ---------------------------------------------------------------------------
// Tab 1: Incident List
// ---------------------------------------------------------------------------

class _IncidentListTab extends StatefulWidget {
  final String initialStatusFilter;
  final String initialPriorityFilter;

  const _IncidentListTab({
    super.key,
    this.initialStatusFilter = 'Semua',
    this.initialPriorityFilter = 'Semua',
  });

  @override
  State<_IncidentListTab> createState() => _IncidentListTabState();
}

class _IncidentListTabState extends State<_IncidentListTab> {
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
      debugPrint('_IncidentListTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didUpdateWidget(_IncidentListTab oldWidget) {
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
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
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Semua insiden fasilitas kampus.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    height: 1.5,
                  ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                        padding: EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 56, color: Color(0xFFD1D5DB)),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada insiden.',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = incidents[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == incidents.length - 1 ? 0 : 14,
                          ),
                          child: _buildIncidentCard(context, item),
                        );
                      }, childCount: incidents.length),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, Incident item) {
    final statusColor = statusColors[item.status] ?? const Color(0xFF6B7280);
    final statusBg = statusBgColors[item.status] ?? const Color(0xFFF3F4F6);
    final categoryIcon = categoryIcons[item.category] ?? Icons.help_outline;
    final categoryColor = categoryColors[item.category] ?? const Color(0xFF9CA3AF);
    final prioColor = priorityColors[item.priority] ?? const Color(0xFF6B7280);
    final prioBg = priorityBgColors[item.priority] ?? const Color(0xFFF3F4F6);

    final canAssign = item.status == statusOpen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
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
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 22),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: prioColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: prioBg, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _statusLabels[item.status] ?? item.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 12, color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.people, size: 12, color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            '${item.confirmationCount} konfirmasi',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          if (item.assignedTo != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.person, size: 12, color: const Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.assignedTo!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (canAssign) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _quickAssign(item),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1,
                                  size: 16,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Staff Workload
// ---------------------------------------------------------------------------

class _StaffWorkloadTab extends StatefulWidget {
  const _StaffWorkloadTab();

  @override
  State<_StaffWorkloadTab> createState() => _StaffWorkloadTabState();
}

class _StaffWorkloadTabState extends State<_StaffWorkloadTab> {
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
      debugPrint('_StaffWorkloadTab._load error: $e');
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
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ringkasan tugas aktif per teknisi.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(_staffLoads.length, (index) {
            final s = _staffLoads[index];
            final barRatio = maxActive > 0 ? s.active / maxActive : 0.0;

            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
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

// ---------------------------------------------------------------------------
// Tab 3: Users
// ---------------------------------------------------------------------------

class _MasterDataTab extends StatefulWidget {
  const _MasterDataTab();

  @override
  State<_MasterDataTab> createState() => _MasterDataTabState();
}

class _MasterDataTabState extends State<_MasterDataTab> {
  final _buildingRepo = BuildingRepository();
  final _categoryRepo = CategoryRepository();
  List<Building> _buildings = [];
  List<ReportCategory> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;
  int? _expandedBuilding;

  static const _iconOptions = <IconData>[
    Icons.ac_unit,
    Icons.lightbulb_outline,
    Icons.bolt,
    Icons.videocam,
    Icons.water_drop,
    Icons.wc,
    Icons.chair_outlined,
    Icons.wifi,
    Icons.cleaning_services,
    Icons.construction,
    Icons.electrical_services,
    Icons.pets,
    Icons.door_front_door_outlined,
    Icons.window,
    Icons.format_paint,
    Icons.coffee,
    Icons.fence,
    Icons.roofing,
    Icons.downhill_skiing,
    Icons.sensor_door,
  ];

  static const _colorOptions = <Color>[
    Color(0xFF3B82F6),
    Color(0xFFFBBF24),
    Color(0xFFF97316),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF6366F1),
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
    Color(0xFF78716C),
    Color(0xFF1C1917),
  ];

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
      final b = await _buildingRepo.getAll();
      final c = await _categoryRepo.getAll();
      if (!mounted) return;
      setState(() {
        _buildings = b;
        _categories = c;
      });
    } catch (e) {
      debugPrint('_MasterDataTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();
    if (_hasError) return ErrorView(message: 'Gagal memuat master data.', onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const Text(
            'Master Data',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lokasi dan kategori insiden.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Text(
                'Lokasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showBuildingSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(_buildings.length, (index) {
            final building = _buildings[index];
            final isExpanded = _expandedBuilding == index;
            return Padding(
              padding: EdgeInsets.only(bottom: index == _buildings.length - 1 ? 0 : 8),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() {
                          _expandedBuilding = isExpanded ? null : index;
                        }),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.business, color: Color(0xFF3B82F6), size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                building.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: const Color(0xFF9CA3AF),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        ...List.generate(building.floors.length, (fIndex) {
                          final floor = building.floors[fIndex];
                          final isLast = fIndex == building.floors.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  floor.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Text(
                                    floor.areas.join(', '),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showBuildingSheet(context, index: index, building: building),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF3B82F6),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => _deleteBuilding(index),
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Hapus'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          Row(
            children: [
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showCategorySheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return GestureDetector(
                onTap: () => _showCategorySheet(context, index: index, category: cat),
                child: Container(
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, color: cat.color, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: cat.color,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBuilding(int index) async {
    final name = _buildings[index].name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Lokasi'),
        content: Text('Hapus "$name" dan semua lantai di dalamnya?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _buildingRepo.delete(index);
      if (!mounted) return;
      if (_expandedBuilding == index) _expandedBuilding = null;
      _load();
    }
  }

  void _showBuildingSheet(BuildContext context, {int? index, Building? building}) {
    final isEditing = building != null;
    final nameController = TextEditingController(text: building?.name ?? '');
    final floorNames = <TextEditingController>[];
    final floorAreas = <TextEditingController>[];

    if (isEditing) {
      for (final f in building.floors) {
        floorNames.add(TextEditingController(text: f.name));
        floorAreas.add(TextEditingController(text: f.areas.join(', ')));
      }
    } else {
      floorNames.add(TextEditingController());
      floorAreas.add(TextEditingController());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Lokasi' : 'Tambah Lokasi',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Gedung',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Lantai',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setSheetState(() {
                            floorNames.add(TextEditingController());
                            floorAreas.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah Lantai'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView(
                      shrinkWrap: true,
                      children: List.generate(floorNames.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: i == floorNames.length - 1 ? 0 : 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: floorNames[i],
                                  decoration: InputDecoration(
                                    labelText: 'Nama Lantai',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: floorAreas[i],
                                  decoration: InputDecoration(
                                    labelText: 'Ruangan (koma)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (floorNames.length > 1)
                                IconButton(
                                  onPressed: () => setSheetState(() {
                                    floorNames[i].dispose();
                                    floorAreas[i].dispose();
                                    floorNames.removeAt(i);
                                    floorAreas.removeAt(i);
                                  }),
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  color: const Color(0xFFEF4444),
                                  visualDensity: VisualDensity.compact,
                                )
                              else
                                const SizedBox(width: 48),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (isEditing)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await _buildingRepo.delete(index!);
                              if (!mounted) return;
                              Navigator.pop(ctx);
                              _load();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text('Hapus'),
                          ),
                        ),
                      if (isEditing) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            final floors = <Floor>[];
                            for (var i = 0; i < floorNames.length; i++) {
                              final fn = floorNames[i].text.trim();
                              if (fn.isEmpty) continue;
                              final areas = floorAreas[i].text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                              floors.add(Floor(name: fn, areas: areas));
                            }
                            if (floors.isEmpty) return;
                            final newBuilding = Building(name: name, floors: floors);
                            if (isEditing) {
                              await _buildingRepo.update(index!, newBuilding);
                            } else {
                              await _buildingRepo.add(newBuilding);
                            }
                            if (!mounted) return;
                            Navigator.pop(ctx);
                            _load();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111827),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(isEditing ? 'Simpan' : 'Tambah'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      for (final c in floorNames) { c.dispose(); }
      for (final c in floorAreas) { c.dispose(); }
    });
  }

  void _showCategorySheet(BuildContext context, {int? index, ReportCategory? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    var selectedIcon = category?.icon ?? _iconOptions.first;
    var selectedColor = category?.color ?? _colorOptions.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Kategori' : 'Tambah Kategori',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ikon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 10,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: _iconOptions.length,
                      itemBuilder: (ctx, i) {
                        final icon = _iconOptions[i];
                        final isSelected = icon == selectedIcon;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedColor.withValues(alpha: 0.15)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(color: selectedColor, width: 2)
                                  : null,
                            ),
                            child: Icon(icon, color: isSelected ? selectedColor : const Color(0xFF6B7280), size: 18),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Warna',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((c) {
                      final isSelected = c == selectedColor;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 6)]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (isEditing)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await _categoryRepo.delete(index!);
                              if (!mounted) return;
                              Navigator.pop(ctx);
                              _load();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text('Hapus'),
                          ),
                        ),
                      if (isEditing) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            final newCat = ReportCategory(
                              name: name,
                              icon: selectedIcon,
                              color: selectedColor,
                            );
                            if (isEditing) {
                              await _categoryRepo.update(index!, newCat);
                            } else {
                              await _categoryRepo.add(newCat);
                            }
                            if (!mounted) return;
                            Navigator.pop(ctx);
                            _load();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111827),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(isEditing ? 'Simpan' : 'Tambah'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => nameController.dispose());
  }

  @override
  void dispose() {
    super.dispose();
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

