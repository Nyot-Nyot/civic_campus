import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../data/repositories/notification_repository.dart';
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

  static const _icons = <IconData>[
    Icons.assignment_outlined,
    Icons.notifications_outlined,
    Icons.person_outline,
  ];

  static const _selectedIcons = <IconData>[
    Icons.assignment,
    Icons.notifications,
    Icons.person,
  ];

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return StaffMyTasksTab(staffName: staffUser.name);
      case 1:
        return const NotificationScreen(showStaffActions: true);
      case 2:
        return ProfileScreen(staffName: staffUser.name);
      default:
        return const SizedBox.shrink();
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(34),
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      if (index == 1) _loadUnreadCount();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
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
                            if (index == 1 && _unreadNotificationCount > 0)
                              Positioned(
                                top: selected ? 4 : 0,
                                right: selected ? 4 : 0,
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
