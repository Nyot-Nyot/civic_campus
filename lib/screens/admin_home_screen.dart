import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../widgets/logout_sheet.dart';
import 'admin/tabs/overview_tab.dart';
import 'admin/tabs/incident_list_tab.dart';
import 'admin/tabs/staff_workload_tab.dart';
import 'admin/tabs/master_data_tab.dart';

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

  static const _icons = <IconData>[
    Icons.dashboard_outlined,
    Icons.list_alt_outlined,
    Icons.bar_chart_outlined,
    Icons.business_outlined,
  ];

  static const _selectedIcons = <IconData>[
    Icons.dashboard,
    Icons.list_alt,
    Icons.bar_chart,
    Icons.business,
  ];

  static const _labels = [
    'Overview',
    'Daftar Insiden',
    'Beban Kerja Staff',
    'Master Data',
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

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0: return AdminOverviewTab(onQuickAction: _onQuickAction);
      case 1: return AdminIncidentListTab(
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
