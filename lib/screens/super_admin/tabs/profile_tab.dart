import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../widgets/logout_sheet.dart';
import '../../login_screen.dart';

class SuperAdminProfileTab extends StatelessWidget {
  const SuperAdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = superAdminUser;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            child: const Icon(Icons.admin_panel_settings, size: 48, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 16),
          Text(user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Super Admin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8B5CF6))),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pengaturan Akun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                const SizedBox(height: 16),
                _ProfileMenuItem(icon: Icons.notifications_outlined, title: 'Notifikasi', trailing: 'Aktif'),
                const Divider(height: 24),
                _ProfileMenuItem(icon: Icons.language_outlined, title: 'Bahasa', trailing: 'Indonesia'),
                const Divider(height: 24),
                _ProfileMenuItem(icon: Icons.info_outline, title: 'Versi Aplikasi', trailing: appVersion),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                LogoutSheet.show(context, () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                });
              },
              icon: const Icon(Icons.logout, size: 18, color: Color(0xFFEF4444)),
              label: const Text('Keluar', style: TextStyle(color: Color(0xFFEF4444))),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF6B7280)),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF111827)))),
        Text(trailing, style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}
