import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/dummy_data.dart';
import '../data/repositories/incident_repository.dart';
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
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
      case 1: return const NotificationScreen();
      case 2: return const ProfileScreen();
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _repo.getAssignedTo(staffUser.name);
      if (!mounted) return;
      setState(() => _tasks = items);
    } catch (e) {
      debugPrint('_MyTasksTab._load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: _isLoading
              ? const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : _tasks.isEmpty
                  ? const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Tidak ada tugas saat ini.',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = _tasks[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _tasks.length - 1 ? 0 : 14,
                          ),
                          child: _buildTaskCard(context, item),
                        );
                      }, childCount: _tasks.length),
                    ),
        ),
      ],
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => IncidentDetailScreen(
                incident: item,
                showStaffActions: true,
              ),
            ),
          );
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 22),
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
                          Icon(Icons.access_time,
                              size: 12, color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            item.timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
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
// Tab 2: Profil — reuse ProfileScreen// ---------------------------------------------------------------------------
