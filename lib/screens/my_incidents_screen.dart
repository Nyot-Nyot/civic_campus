import 'package:flutter/material.dart';

class _MyIncident {
  final String id;
  final String title;
  final String location;
  final String category;
  final String status;
  final String timeAgo;
  final int photoCount;
  final int confirmationCount;
  final String description;

  const _MyIncident({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.status,
    required this.timeAgo,
    this.photoCount = 1,
    this.confirmationCount = 0,
    this.description = '',
  });
}

const _allIncidents = <_MyIncident>[
  _MyIncident(
    id: 'INC-001',
    title: 'AC ruang kuliah tidak dingin',
    location: 'Gedung F / F101',
    category: 'AC',
    status: 'In Progress',
    timeAgo: '4 jam lalu',
    photoCount: 2,
    confirmationCount: 3,
    description: 'AC tidak mengeluarkan udara dingin sejak pagi, remote tidak berfungsi.',
  ),
  _MyIncident(
    id: 'INC-002',
    title: 'Lampu koridor mati',
    location: 'Gedung A / Lantai 2 / Koridor',
    category: 'Lampu',
    status: 'Open',
    timeAgo: '1 hari lalu',
    photoCount: 1,
    confirmationCount: 5,
    description: '3 lampu koridor mati total, area gelap.',
  ),
  _MyIncident(
    id: 'INC-003',
    title: 'Proyektor tidak menyala',
    location: 'Gedung B / Lab Komputer',
    category: 'Proyektor',
    status: 'Assigned',
    timeAgo: '2 hari lalu',
    photoCount: 1,
    confirmationCount: 1,
  ),
  _MyIncident(
    id: 'INC-004',
    title: 'Toilet mampet',
    location: 'Gedung F / Lantai 2 / Toilet',
    category: 'Toilet',
    status: 'Resolved',
    timeAgo: '3 hari lalu',
    photoCount: 3,
    confirmationCount: 2,
  ),
  _MyIncident(
    id: 'INC-005',
    title: 'Meja kursi rusak',
    location: 'Asrama Putra / Lantai 2 / Kamar 201',
    category: 'Furnitur',
    status: 'Closed',
    timeAgo: '1 minggu lalu',
    photoCount: 1,
    confirmationCount: 0,
  ),
  _MyIncident(
    id: 'INC-006',
    title: 'WiFi lambat',
    location: 'Perpustakaan / Lantai 1 / Ruang Baca',
    category: 'WiFi',
    status: 'Open',
    timeAgo: '30 menit lalu',
    photoCount: 1,
    confirmationCount: 8,
  ),
  _MyIncident(
    id: 'INC-007',
    title: 'Pipa air bocor',
    location: 'Gedung A / Lantai 1 / Toilet',
    category: 'Pipa Air',
    status: 'In Progress',
    timeAgo: '6 jam lalu',
    photoCount: 2,
    confirmationCount: 4,
  ),
  _MyIncident(
    id: 'INC-008',
    title: 'Kebersihan area baca',
    location: 'Perpustakaan / Lantai 1 / Area Buku',
    category: 'Kebersihan',
    status: 'Closed',
    timeAgo: '2 minggu lalu',
    photoCount: 1,
    confirmationCount: 2,
  ),
];

const _statusColors = <String, Color>{
  'Open': Color(0xFF1D4ED8),
  'Assigned': Color(0xFF374151),
  'In Progress': Color(0xFFC2410C),
  'Resolved': Color(0xFF047857),
  'Closed': Color(0xFF6B7280),
};

const _statusBgColors = <String, Color>{
  'Open': Color(0xFFEFF6FF),
  'Assigned': Color(0xFFEEF2F6),
  'In Progress': Color(0xFFFFEDD5),
  'Resolved': Color(0xFFD1FAE5),
  'Closed': Color(0xFFF3F4F6),
};

const _categoryIcons = <String, IconData>{
  'AC': Icons.ac_unit,
  'Lampu': Icons.lightbulb_outline,
  'Listrik': Icons.bolt,
  'Proyektor': Icons.videocam,
  'Pipa Air': Icons.water_drop,
  'Toilet': Icons.wc,
  'Furnitur': Icons.chair_outlined,
  'WiFi': Icons.wifi,
  'Kebersihan': Icons.cleaning_services,
  'Struktur': Icons.construction,
};

const _categoryColors = <String, Color>{
  'AC': Color(0xFF3B82F6),
  'Lampu': Color(0xFFFBBF24),
  'Listrik': Color(0xFFF97316),
  'Proyektor': Color(0xFF8B5CF6),
  'Pipa Air': Color(0xFF06B6D4),
  'Toilet': Color(0xFF10B981),
  'Furnitur': Color(0xFFEC4899),
  'WiFi': Color(0xFF6366F1),
  'Kebersihan': Color(0xFF14B8A6),
  'Struktur': Color(0xFFEF4444),
};

class MyIncidentsScreen extends StatelessWidget {
  const MyIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MyIncidentsBody();
  }
}

class _MyIncidentsBody extends StatefulWidget {
  const _MyIncidentsBody();

  @override
  State<_MyIncidentsBody> createState() => _MyIncidentsBodyState();
}

class _MyIncidentsBodyState extends State<_MyIncidentsBody> {
  int _selectedFilter = 0;
  static const _filters = ['Semua', 'Aktif', 'Selesai'];

  List<_MyIncident> get _filtered {
    switch (_selectedFilter) {
      case 1:
        return _allIncidents
            .where((i) => !_isClosedOrResolved(i.status))
            .toList();
      case 2:
        return _allIncidents
            .where((i) => _isClosedOrResolved(i.status))
            .toList();
      default:
        return _allIncidents;
    }
  }

  bool _isClosedOrResolved(String status) {
    return status == 'Closed' || status == 'Resolved';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Insiden Saya',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pantau status laporan yang telah Anda buat.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilter == index;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(19),
                        onTap: () => setState(() => _selectedFilter = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF111827)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF111827)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
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
        const SizedBox(height: 20),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 56, color: Color(0xFFD1D5DB)),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada laporan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return _buildIncidentCard(context, filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIncidentCard(BuildContext context, _MyIncident item) {
    final statusColor = _statusColors[item.status] ?? const Color(0xFF6B7280);
    final statusBg = _statusBgColors[item.status] ?? const Color(0xFFF3F4F6);
    final categoryIcon =
        _categoryIcons[item.category] ?? Icons.help_outline;
    final categoryColor =
        _categoryColors[item.category] ?? const Color(0xFF9CA3AF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Detail ${item.id} akan segera hadir.'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 12, color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 12, color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            item.timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          if (item.confirmationCount > 0) ...[
                            const SizedBox(width: 14),
                            Icon(Icons.people,
                                size: 12, color: const Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Text(
                              '+${item.confirmationCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                          if (item.photoCount > 1) ...[
                            const SizedBox(width: 14),
                            Icon(Icons.photo_library,
                                size: 12, color: const Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Text(
                              '${item.photoCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    size: 20, color: const Color(0xFFD1D5DB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
