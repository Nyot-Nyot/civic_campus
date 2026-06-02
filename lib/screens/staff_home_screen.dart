import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/dummy_data.dart';
import '../data/repositories/incident_repository.dart';
import '../data/repositories/notification_repository.dart';
import 'incident_detail_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  static const routeName = '/staff-home';

  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _selectedIndex = 0;
  int _unreadNotificationCount = 0;
  final _notificationRepo = NotificationRepository();

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationRepo.getUnreadCount();
    if (!mounted) return;
    setState(() => _unreadNotificationCount = count);
  }

  static const _icons = <IconData>[
    Icons.assignment_outlined,
    Icons.notifications_outlined,
    Icons.person_outline,
  ];

  static const _selectedIcons = <IconData>[
    Icons.assignment,
    Icons.notifications,
    Icons.person,
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(34),
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      if (index == 1) _loadUnreadCount();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
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
                            if (index == 1 && _unreadNotificationCount > 0)
                              Positioned(
                                top: selected ? 4 : 0,
                                right: selected ? 4 : 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
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
      case 0: return const _MyTasksTab();
      case 1: return const NotificationScreen(showStaffActions: true);
      case 2: return ProfileScreen(staffName: staffUser.name);
      default: return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Tab 0: Tugas Saya — incidents assigned to this staff
// ---------------------------------------------------------------------------

class _MyTasksTab extends StatefulWidget {
  const _MyTasksTab();

  @override
  State<_MyTasksTab> createState() => _MyTasksTabState();
}

class _MyTasksTabState extends State<_MyTasksTab> {
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
      final items = await _repo.getAssignedTo(staffUser.name);
      if (!mounted) return;
      setState(() {
        _tasks = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('_MyTasksTab._load error: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
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
                  'Halo, ${staffUser.name}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Berikut tugas yang ditugaskan kepada Anda.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    height: 1.5,
                  ),
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
                          color: selected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                        backgroundColor: const Color(0xFFF3F4F6),
                        selectedColor: const Color(0xFF111827),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8),
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
                ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : _hasError
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 56,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Gagal memuat tugas.',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextButton(
                              onPressed: _load,
                              child: Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : tasks.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 56,
                                color: Color(0xFFD1D5DB),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada tugas saat ini.',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tugas baru akan muncul di sini\nsetelah admin menugaskan Anda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFD1D5DB),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = tasks[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == tasks.length - 1 ? 0 : 14,
                          ),
                          child: _buildTaskCard(context, item),
                        );
                      }, childCount: tasks.length),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDots(String currentStatus) {
    final currentIdx = statusFlow.indexOf(currentStatus).clamp(0, statusFlow.length - 1);
    return Row(
      children: List.generate(statusFlow.length, (index) {
        final isCompleted = index < currentIdx;
        final isCurrent = index == currentIdx;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(
              right: index < statusFlow.length - 1 ? 4 : 0,
            ),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF047857)
                  : isCurrent
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTaskCard(BuildContext context, Incident item) {
    final statusColor =
        statusColors[item.status] ?? const Color(0xFF6B7280);
    final statusBg =
        statusBgColors[item.status] ?? const Color(0xFFF3F4F6);
    final categoryIcon =
        categoryIcons[item.category] ?? Icons.help_outline;
    final categoryColor =
        categoryColors[item.category] ?? const Color(0xFF9CA3AF);
    final prioColor =
        priorityColors[item.priority] ?? const Color(0xFF6B7280);
    final prioBg =
        priorityBgColors[item.priority] ?? const Color(0xFFF3F4F6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => IncidentDetailScreen(
                incident: item,
                showStaffActions: true,
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
                          border: Border.all(
                            color: prioBg,
                            width: 2,
                          ),
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
                              item.status,
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Tooltip(
                            message: item.isOverdue() ? 'Terlambat' : '',
                            child: Semantics(
                              label: item.isOverdue()
                                  ? 'Laporan terlambat'
                                  : '',
                              child: Icon(Icons.access_time,
                                  size: 12,
                                  color: item.isOverdue()
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF9CA3AF)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isOverdue()
                                ? '${item.timeAgo} (terlambat)'
                                : item.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: item.isOverdue()
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF9CA3AF),
                              fontWeight: item.isOverdue()
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (item.confirmationCount > 0) ...[
                            const SizedBox(width: 14),
                            Icon(Icons.people,
                                size: 12, color: const Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Text(
                              '+${item.confirmationCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildStatusDots(item.status),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    size: 20, color: const Color(0xFFD1D5DB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Notifikasi — reuse NotificationScreen
// Tab 2: Profil — reuse ProfileScreen
// ---------------------------------------------------------------------------
