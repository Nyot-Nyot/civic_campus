import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/repositories/incident_repository.dart';
import '../data/repositories/notification_repository.dart';
import 'incident_detail_screen.dart';
import 'my_incidents_screen.dart';
import 'new_report_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'student/tabs/home_tab.dart';

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

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 2:
        return const MyIncidentsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return StudentHomeTab(
          isLoading: _isLoading,
          activeIncidents: _activeIncidents,
          unreadNotificationCount: _unreadNotificationCount,
          onRefresh: _loadData,
          onNewReport: ({initialCategory}) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewReportScreen(initialCategory: initialCategory),
              ),
            );
          },
          onOpenNotification: () {
            Navigator.of(context).push<int>(
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            ).then((unread) {
              if (mounted) setState(() => _unreadNotificationCount = unread ?? 0);
            });
          },
          onIncidentTap: (incident) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => IncidentDetailScreen(incident: incident)),
            );
          },
        );
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
