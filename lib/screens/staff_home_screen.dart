import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../data/repositories/notification_repository.dart';
import '../widgets/app_bottom_nav.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'staff/tabs/my_tasks_tab.dart';

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

  List<AppBottomNavItem> get _navItems => [
    const AppBottomNavItem(icon: Icons.assignment_outlined, selectedIcon: Icons.assignment),
    AppBottomNavItem(icon: Icons.notifications_outlined, selectedIcon: Icons.notifications, showBadge: _unreadNotificationCount > 0),
    const AppBottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person),
  ];

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return StaffMyTasksTab(staffName: staffUser.name);
      case 1:
        return const NotificationScreen(showStaffActions: true);
      case 2:
        return ProfileScreen(user: staffUser);
      default:
        return const SizedBox.shrink();
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
          setState(() => _selectedIndex = index);
          if (index == 1) _loadUnreadCount();
        },
      ),
    );
  }
}
