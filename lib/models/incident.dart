import 'package:flutter/material.dart';

class Incident {
  final String id;
  final String title;
  final String location;
  final String category;
  final String status;
  final String timeAgo;
  final int photoCount;
  final int confirmationCount;
  final String description;

  const Incident({
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

const allIncidents = <Incident>[
  Incident(
    id: 'INC-001',
    title: 'AC ruang kuliah tidak dingin',
    location: 'Gedung F / F101',
    category: 'AC',
    status: 'In Progress',
    timeAgo: '4 jam lalu',
    photoCount: 2,
    confirmationCount: 3,
    description:
        'AC tidak mengeluarkan udara dingin sejak pagi, remote tidak berfungsi.',
  ),
  Incident(
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
  Incident(
    id: 'INC-003',
    title: 'Proyektor tidak menyala',
    location: 'Gedung B / Lab Komputer',
    category: 'Proyektor',
    status: 'Assigned',
    timeAgo: '2 hari lalu',
    photoCount: 1,
    confirmationCount: 1,
  ),
  Incident(
    id: 'INC-004',
    title: 'Toilet mampet',
    location: 'Gedung F / Lantai 2 / Toilet',
    category: 'Toilet',
    status: 'Resolved',
    timeAgo: '3 hari lalu',
    photoCount: 3,
    confirmationCount: 2,
  ),
  Incident(
    id: 'INC-005',
    title: 'Meja kursi rusak',
    location: 'Asrama Putra / Lantai 2 / Kamar 201',
    category: 'Furnitur',
    status: 'Closed',
    timeAgo: '1 minggu lalu',
    photoCount: 1,
    confirmationCount: 0,
  ),
  Incident(
    id: 'INC-006',
    title: 'WiFi lambat',
    location: 'Perpustakaan / Lantai 1 / Ruang Baca',
    category: 'WiFi',
    status: 'Open',
    timeAgo: '30 menit lalu',
    photoCount: 1,
    confirmationCount: 8,
  ),
  Incident(
    id: 'INC-007',
    title: 'Pipa air bocor',
    location: 'Gedung A / Lantai 1 / Toilet',
    category: 'Pipa Air',
    status: 'In Progress',
    timeAgo: '6 jam lalu',
    photoCount: 2,
    confirmationCount: 4,
  ),
  Incident(
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

const statusColors = <String, Color>{
  'Open': Color(0xFF1D4ED8),
  'Assigned': Color(0xFF374151),
  'In Progress': Color(0xFFC2410C),
  'Resolved': Color(0xFF047857),
  'Closed': Color(0xFF6B7280),
};

const statusBgColors = <String, Color>{
  'Open': Color(0xFFEFF6FF),
  'Assigned': Color(0xFFEEF2F6),
  'In Progress': Color(0xFFFFEDD5),
  'Resolved': Color(0xFFD1FAE5),
  'Closed': Color(0xFFF3F4F6),
};

const categoryIcons = <String, IconData>{
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

const categoryColors = <String, Color>{
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
