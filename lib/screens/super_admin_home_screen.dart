import 'package:flutter/material.dart';

import 'super_admin/tabs/dashboard_tab.dart';
import 'super_admin/tabs/users_tab.dart';
import 'super_admin/tabs/incident_list_tab.dart';
import 'super_admin/tabs/system_config_tab.dart';
import 'super_admin/tabs/profile_tab.dart';

class SuperAdminHomeScreen extends StatefulWidget {
  static const routeName = '/super-admin-home';

  const SuperAdminHomeScreen({super.key});

  @override
  State<SuperAdminHomeScreen> createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  int _selectedIndex = 0;

  static const _icons = <IconData>[
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.list_alt_outlined,
    Icons.settings_outlined,
    Icons.person_outline,
  ];

  static const _selectedIcons = <IconData>[
    Icons.dashboard,
    Icons.people,
    Icons.list_alt,
    Icons.settings,
    Icons.person,
  ];

  static const _labels = [
    'Dashboard',
    'Users',
    'Insiden',
    'Konfigurasi',
    'Profile',
  ];

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: const [
        SuperAdminDashboardTab(),
        SuperAdminUsersTab(),
        SuperAdminIncidentListTab(
          initialStatusFilter: 'Semua',
          initialPriorityFilter: 'Semua',
        ),
        SuperAdminSystemConfigTab(),
        SuperAdminProfileTab(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody()),
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
                final icon = selected ? _selectedIcons[index] : _icons[index];
                return Expanded(
                  child: Tooltip(
                    message: _labels[index],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(34),
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Semantics(
                          label: _labels[index],
                          button: true,
                          selected: selected,
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
                                color: selected ? Colors.white : const Color(0xFF9CA3AF),
                                size: selected ? 28 : 24,
                              ),
                            ),
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
