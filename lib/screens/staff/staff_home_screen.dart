import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/api/realtime_service.dart';
import 'package:civic_campus/data/providers/auth_provider.dart';
import 'package:civic_campus/data/providers/notification_provider.dart';
import 'package:civic_campus/widgets/app_bottom_nav.dart';
import 'package:civic_campus/screens/shared/notification_screen.dart';
import 'package:civic_campus/screens/shared/profile_screen.dart';
import 'package:civic_campus/screens/staff/tabs/my_tasks_tab.dart';

class StaffHomeScreen extends StatefulWidget {
  static const routeName = '/staff-home';

  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _selectedIndex = 0;
  int _unreadNotificationCount = 0;
  final _realtimeService = RealtimeService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUnreadCount();
      _connectRealtime();
    });
  }

  @override
  void dispose() {
    _realtimeService.disconnect();
    super.dispose();
  }

  Future<void> _connectRealtime() async {
    final auth = context.read<AuthProvider>();
    final token = auth.accessToken;
    final userId = auth.userId;
    if (token == null || userId == null) return;

    _realtimeService.setOnNewNotification((_) {
      if (mounted) _loadUnreadCount();
    });
    await _realtimeService.connect(token);
    _realtimeService.subscribe('notifications:$userId');
  }

  Future<void> _loadUnreadCount() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId != null) {
      final notifProvider = context.read<NotificationProvider>();
      await notifProvider.load(userId);
      if (!mounted) return;
      setState(() => _unreadNotificationCount = notifProvider.unreadCount);
    }
  }

  List<AppBottomNavItem> get _navItems => [
    const AppBottomNavItem(icon: Icons.assignment_outlined, selectedIcon: Icons.assignment),
    AppBottomNavItem(icon: Icons.notifications_outlined, selectedIcon: Icons.notifications, showBadge: _unreadNotificationCount > 0),
    const AppBottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person),
  ];

  Widget _buildBody(BuildContext context) {
    final profile = context.read<AuthProvider>().profile;
    final staffName = profile?['name'] as String? ?? 'Staff';
    switch (_selectedIndex) {
      case 0:
        return StaffMyTasksTab(staffName: staffName);
      case 1:
        return const NotificationScreen(showStaffActions: true);
      case 2:
        return ProfileScreen(user: profile);
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
          _loadUnreadCount();
        },
      ),
    );
  }
}
