import 'package:flutter/material.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/repositories/incident_repository.dart';
import 'package:civic_campus/data/repositories/notification_repository.dart';
import 'package:civic_campus/widgets/app_bottom_nav.dart';
import 'package:civic_campus/screens/shared/incident/detail/incident_detail_screen.dart';
import 'package:civic_campus/screens/student/my_incidents_screen.dart';
import 'package:civic_campus/screens/student/new_report_screen.dart';
import 'package:civic_campus/screens/shared/notification_screen.dart';
import 'package:civic_campus/screens/shared/profile_screen.dart';
import 'package:civic_campus/screens/student/tabs/home_tab.dart';

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

  static const _navItems = [
    AppBottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home),
    AppBottomNavItem(icon: Icons.add_circle_outline, selectedIcon: Icons.add_circle),
    AppBottomNavItem(icon: Icons.description_outlined, selectedIcon: Icons.description),
    AppBottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person),
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
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        items: _navItems,
        onItemSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewReportScreen()),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }
}
