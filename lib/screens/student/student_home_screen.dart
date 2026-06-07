import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/providers/auth_provider.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/data/providers/notification_provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      context.read<IncidentProvider>().loadAll(reporterId: userId);
      if (userId != null) {
        context.read<NotificationProvider>().load(userId);
      }
    });
  }

  List<Incident> get _activeIncidents {
    final provider = context.read<IncidentProvider>();
    return provider.incidents
        .where((m) => !_isClosedOrResolved(m['status'] as String? ?? ''))
        .map(_mapToIncident)
        .toList();
  }

  bool _isClosedOrResolved(String status) {
    return status == 'Closed' || status == 'Resolved';
  }

  Incident _mapToIncident(Map<String, dynamic> m) {
    return Incident(
      id: m['id'] as String? ?? '',
      title: m['title'] as String? ?? '',
      location: (m['location_name'] as String?) ?? (m['location_id'] as String? ?? ''),
      category: m['category_name'] as String? ?? '',
      status: m['status'] as String? ?? 'Open',
      timeAgo: m['updated_at'] as String? ?? '',
      photoCount: 0,
      confirmationCount: (m['confirm_count'] as int?) ?? 0,
      description: m['description'] as String? ?? '',
      assignedTo: m['assigned_to'] as String?,
      priority: m['priority_label'] as String? ?? 'Sedang',
      createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static const _navItems = [
    AppBottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home),
    AppBottomNavItem(icon: Icons.add_circle_outline, selectedIcon: Icons.add_circle),
    AppBottomNavItem(icon: Icons.description_outlined, selectedIcon: Icons.description),
    AppBottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person),
  ];

  Widget _buildBody(BuildContext context) {
    final incidentProvider = context.watch<IncidentProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    switch (_selectedIndex) {
      case 2:
        return const MyIncidentsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return StudentHomeTab(
          isLoading: incidentProvider.isLoading,
          activeIncidents: _activeIncidents,
          unreadNotificationCount: notificationProvider.unreadCount,
          onRefresh: () => incidentProvider.loadAll(
            reporterId: context.read<AuthProvider>().userId,
          ),
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
            );
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
