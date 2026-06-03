import 'package:flutter/material.dart';

import 'package:civic_campus/screens/auth/login_screen.dart';
import 'package:civic_campus/widgets/app_bottom_nav.dart';
import 'package:civic_campus/widgets/logout_sheet.dart';
import 'package:civic_campus/screens/admin/tabs/overview_tab.dart';
import 'package:civic_campus/screens/shared/incident/incident_list_tab.dart';
import 'package:civic_campus/screens/admin/tabs/staff_workload_tab.dart';
import 'package:civic_campus/screens/admin/tabs/master_data_tab.dart';

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

  static const _navItems = [
    AppBottomNavItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Overview'),
    AppBottomNavItem(icon: Icons.list_alt_outlined, selectedIcon: Icons.list_alt, label: 'Daftar Insiden'),
    AppBottomNavItem(icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: 'Beban Kerja Staff'),
    AppBottomNavItem(icon: Icons.business_outlined, selectedIcon: Icons.business, label: 'Master Data'),
  ];

  void _onQuickAction(String statusFilter) {
    setState(() {
      _incidentStatusFilter = statusFilter;
      _incidentPriorityFilter = 'Semua';
      _selectedIndex = 1;
    });
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
                    onTap: () {
                      LogoutSheet.show(context, () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      });
                    },
                    child: const Icon(Icons.logout, size: 20, color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        items: _navItems,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0: return AdminOverviewTab(onQuickAction: _onQuickAction);
      case 1: return SharedIncidentListTab(
        key: ValueKey('$_incidentStatusFilter$_incidentPriorityFilter'),
        initialStatusFilter: _incidentStatusFilter,
        initialPriorityFilter: _incidentPriorityFilter,
      );
      case 2: return const AdminStaffWorkloadTab();
      case 3: return const AdminMasterDataTab();
      default: return const SizedBox.shrink();
    }
  }
}
