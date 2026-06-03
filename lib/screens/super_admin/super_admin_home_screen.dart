import 'package:flutter/material.dart';

import 'package:civic_campus/data/dummy_data.dart';
import 'package:civic_campus/widgets/app_bottom_nav.dart';
import 'package:civic_campus/screens/shared/profile_screen.dart';
import 'package:civic_campus/screens/shared/incident/incident_list_tab.dart';
import 'package:civic_campus/screens/super_admin/tabs/dashboard_tab.dart';
import 'package:civic_campus/screens/super_admin/tabs/system_config_tab.dart';
import 'package:civic_campus/screens/super_admin/tabs/users_tab.dart';

class SuperAdminHomeScreen extends StatefulWidget {
  static const routeName = '/super-admin-home';

  const SuperAdminHomeScreen({super.key});

  @override
  State<SuperAdminHomeScreen> createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  int _selectedIndex = 0;

  static const _navItems = [
    AppBottomNavItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Dashboard'),
    AppBottomNavItem(icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Users'),
    AppBottomNavItem(icon: Icons.list_alt_outlined, selectedIcon: Icons.list_alt, label: 'Insiden'),
    AppBottomNavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Konfigurasi'),
    AppBottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
  ];

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        const SuperAdminDashboardTab(),
        const SuperAdminUsersTab(),
        const SharedIncidentListTab(),
        const SuperAdminSystemConfigTab(),
        const ProfileScreen(user: superAdminUser),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        items: _navItems,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
