import 'package:flutter/material.dart';

class _Notification {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  bool isUnread;
  final IconData icon;
  final Color iconColor;

  _Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isUnread = true,
    required this.icon,
    required this.iconColor,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notifications = <_Notification>[
    _Notification(
      id: 'N-001',
      title: 'Laporan Dalam Proses',
      body:
          'Laporan INC-001 (AC ruang kuliah) sedang ditangani oleh tim teknis.',
      timeAgo: '5 menit lalu',
      icon: Icons.engineering_outlined,
      iconColor: const Color(0xFFC2410C),
    ),
    _Notification(
      id: 'N-002',
      title: 'Laporan Telah Selesai',
      body: 'Laporan INC-004 (Toilet mampet) telah ditandai selesai.',
      timeAgo: '1 jam lalu',
      icon: Icons.check_circle_outline,
      iconColor: const Color(0xFF047857),
    ),
    _Notification(
      id: 'N-003',
      title: 'Ada Laporan Serupa',
      body: 'Mahasiswa lain melaporkan masalah lampu di Gedung A yang sama.',
      timeAgo: '2 jam lalu',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFF97316),
    ),
    _Notification(
      id: 'N-004',
      title: 'Status Diperbarui',
      body: 'Laporan INC-002 (Lampu koridor) telah di-assign ke petugas.',
      timeAgo: '5 jam lalu',
      isUnread: false,
      icon: Icons.swap_horiz,
      iconColor: const Color(0xFF3B82F6),
    ),
    _Notification(
      id: 'N-005',
      title: 'Laporan Dikonfirmasi',
      body: '3 mahasiswa mengkonfirmasi laporan INC-006 (WiFi lambat).',
      timeAgo: '1 hari lalu',
      isUnread: false,
      icon: Icons.people_outline,
      iconColor: const Color(0xFF8B5CF6),
    ),
    _Notification(
      id: 'N-006',
      title: 'Permintaan Reopen Diterima',
      body: 'Permintaan pembukaan kembali laporan INC-003 telah disetujui.',
      timeAgo: '2 hari lalu',
      isUnread: false,
      icon: Icons.refresh,
      iconColor: const Color(0xFF10B981),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n.isUnread).length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(unreadCount);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F5F7),
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(unreadCount),
          ),
          title: const Text(
            'Notifikasi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          actions: [
            if (unreadCount > 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    for (final n in _notifications) {
                      n.isUnread = false;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua notifikasi ditandai dibaca.'),
                    ),
                  );
                },
                child: const Text(
                  'Tandai dibaca',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Pantau update terbaru dari laporan Anda.',
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFF1D4ED8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$unreadCount notifikasi belum dibaca',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: _notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 56,
                            color: Color(0xFFD1D5DB),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada notifikasi',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < _notifications.length - 1 ? 10 : 0,
                          ),
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: item.iconColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          item.icon,
                                          color: item.iconColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                if (item.isUnread)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(
                                                            0xFF1D4ED8,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                  ),
                                                if (item.isUnread)
                                                  const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item.title,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: item.isUnread
                                                          ? const Color(
                                                              0xFF111827,
                                                            )
                                                          : const Color(
                                                              0xFF6B7280,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.body,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6B7280),
                                                height: 1.4,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              item.timeAgo,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF9CA3AF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
