import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/dummy_data.dart';
import '../data/repositories/incident_repository.dart';
import '../data/repositories/notification_repository.dart';
import 'incident_detail_screen.dart';
import 'my_incidents_screen.dart';
import 'new_report_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  static const routeName = '/student-home';

  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  int _unreadNotificationCount = 0;
  List<Incident> _activeIncidents = [];
  bool _isLoading = true;

  final _incidentRepo = IncidentRepository();
  final _notificationRepo = NotificationRepository();

  static const _bottomNavigationIcons = <IconData>[
    Icons.home_outlined,
    Icons.add_circle_outline,
    Icons.description_outlined,
    Icons.person_outline,
  ];

  static const _bottomNavigationSelectedIcons = <IconData>[
    Icons.home,
    Icons.add_circle,
    Icons.description,
    Icons.person,
  ];

  static const _categories = homeCategoryNames;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final active = await _incidentRepo.getActive();
      final unread = await _notificationRepo.getUnreadCount();
      if (!mounted) return;
      setState(() {
        _activeIncidents = active;
        _unreadNotificationCount = unread;
      });
    } catch (e) {
      debugPrint('_loadData error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategoryChipTap(BuildContext context, String category) {
    String? initialCategory;
    if (category == 'Toilet' || category == 'WiFi') {
      initialCategory = category;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewReportScreen(initialCategory: initialCategory),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Halo, Mahasiswa',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Lihat status laporan atau laporkan masalah baru dari sini.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        tooltip: 'Notifikasi',
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          minimumSize: const Size(52, 52),
                        ),
                        onPressed: () async {
                          final unread = await Navigator.of(context).push<int>(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationScreen(),
                            ),
                          );
                          if (!mounted) return;
                          setState(() => _unreadNotificationCount = unread ?? 0);
                        },
                      ),
                      if (_unreadNotificationCount > 0)
                        Positioned(
                          top: 6,
                          right: 6,
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
                ],
              ),
              const SizedBox(height: 28),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Butuh laporan cepat?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Laporkan masalah fasilitas kampus dengan foto dan lokasi cepat.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const NewReportScreen(),
                            ),
                          );
                        },
                        child: const Text('Laporkan Masalah'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Kategori populer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return ActionChip(
                      label: Text(_categories[index]),
                      onPressed: () => _onCategoryChipTap(context, _categories[index]),
                      backgroundColor: const Color(0xFFF3F4F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Laporan aktif saya',
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
              : _activeIncidents.isEmpty
                  ? const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Tidak ada laporan aktif.',
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
                        final item = _activeIncidents[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _activeIncidents.length - 1 ? 0 : 14,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentDetailScreen(incident: item),
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
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              item.location,
                                              style: const TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: statusBgColors[
                                                            item.status] ??
                                                        const Color(0xFFEFF6FF),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                  child: Text(
                                                    item.status,
                                                    style: TextStyle(
                                                      color: statusColors[
                                                              item.status] ??
                                                          const Color(0xFF1D4ED8),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  item.timeAgo,
                                                  style: const TextStyle(
                                                    color: Color(0xFF9CA3AF),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: (categoryColors[
                                                      item.category] ??
                                                  const Color(0xFF3B82F6))
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          categoryIcons[item.category] ??
                                              Icons.report_problem,
                                          color: categoryColors[
                                                  item.category] ??
                                              const Color(0xFF3B82F6),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: _activeIncidents.length),
                    ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 1:
        return const SizedBox.shrink();
      case 2:
        return const MyIncidentsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab(context);
    }
  }

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
              boxShadow: [
                const BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.18),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_bottomNavigationIcons.length, (index) {
                final selected = _selectedIndex == index;
                final icon = selected
                    ? _bottomNavigationSelectedIcons[index]
                    : _bottomNavigationIcons[index];
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(34),
                    onTap: () {
                      if (index == 1) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NewReportScreen(),
                          ),
                        );
                      } else {
                        setState(() {
                          _selectedIndex = index;
                        });
                      }
                    },
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
}
