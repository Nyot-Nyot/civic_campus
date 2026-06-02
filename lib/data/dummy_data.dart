import 'package:flutter/material.dart';

import 'models/incident.dart';
import 'models/notification.dart';
import 'models/building.dart';
import 'models/category.dart';
import 'models/user.dart';
import 'models/suggestion.dart';

// ---------------------------------------------------------------------------
// INCIDENTS
// ---------------------------------------------------------------------------

final allIncidents = <Incident>[
  Incident(
    id: 'INC-001',
    title: 'AC ruang kuliah tidak dingin',
    location: 'Gedung F / F101',
    category: 'AC',
    status: statusInProgress,
    timeAgo: '4 jam lalu',
    photoCount: 2,
    confirmationCount: 3,
    description:
        'AC tidak mengeluarkan udara dingin sejak pagi, remote tidak berfungsi.',
    assignedTo: 'Budi Teknisi',
    priority: 'Tinggi',
    createdAt: DateTime(2026, 6, 2, 6, 0),
  ),
  Incident(
    id: 'INC-002',
    title: 'Lampu koridor mati',
    location: 'Gedung A / Lantai 2 / Koridor',
    category: 'Lampu',
    status: statusOpen,
    timeAgo: '1 hari lalu',
    photoCount: 1,
    confirmationCount: 5,
    description: '3 lampu koridor mati total, area gelap.',
    priority: 'Sedang',
    createdAt: DateTime(2026, 6, 1, 10, 0),
  ),
  Incident(
    id: 'INC-003',
    title: 'Proyektor tidak menyala',
    location: 'Gedung B / Lab Komputer',
    category: 'Proyektor',
    status: statusAssigned,
    timeAgo: '2 hari lalu',
    photoCount: 1,
    confirmationCount: 1,
    assignedTo: 'Budi Teknisi',
    priority: 'Sedang',
    createdAt: DateTime(2026, 5, 31, 10, 0),
  ),
  Incident(
    id: 'INC-004',
    title: 'Toilet mampet',
    location: 'Gedung F / Lantai 2 / Toilet',
    category: 'Toilet',
    status: statusResolved,
    timeAgo: '3 hari lalu',
    photoCount: 3,
    confirmationCount: 2,
    assignedTo: 'Budi Teknisi',
    priority: 'Rendah',
    createdAt: DateTime(2026, 5, 30, 10, 0),
  ),
  Incident(
    id: 'INC-005',
    title: 'Meja kursi rusak',
    location: 'Asrama Putra / Lantai 2 / Kamar 201',
    category: 'Furnitur',
    status: statusClosed,
    timeAgo: '1 minggu lalu',
    photoCount: 1,
    confirmationCount: 0,
    priority: 'Rendah',
    createdAt: DateTime(2026, 5, 26, 10, 0),
  ),
  Incident(
    id: 'INC-006',
    title: 'WiFi lambat',
    location: 'Perpustakaan / Lantai 1 / Ruang Baca',
    category: 'WiFi',
    status: statusOpen,
    timeAgo: '30 menit lalu',
    photoCount: 1,
    confirmationCount: 8,
    priority: 'Tinggi',
    createdAt: DateTime(2026, 6, 2, 9, 30),
  ),
  Incident(
    id: 'INC-007',
    title: 'Pipa air bocor',
    location: 'Gedung A / Lantai 1 / Toilet',
    category: 'Pipa Air',
    status: statusInProgress,
    timeAgo: '6 jam lalu',
    photoCount: 2,
    confirmationCount: 4,
    assignedTo: 'Budi Teknisi',
    priority: 'Tinggi',
    createdAt: DateTime(2026, 6, 2, 4, 0),
  ),
  Incident(
    id: 'INC-008',
    title: 'Kebersihan area baca',
    location: 'Perpustakaan / Lantai 1 / Area Buku',
    category: 'Kebersihan',
    status: statusClosed,
    timeAgo: '2 minggu lalu',
    photoCount: 1,
    confirmationCount: 2,
    priority: 'Rendah',
    createdAt: DateTime(2026, 5, 19, 10, 0),
  ),
];

const statusColors = <String, Color>{
  statusOpen: Color(0xFF1D4ED8),
  statusAssigned: Color(0xFF374151),
  statusInProgress: Color(0xFFC2410C),
  statusResolved: Color(0xFF047857),
  statusClosed: Color(0xFF6B7280),
};

const statusBgColors = <String, Color>{
  statusOpen: Color(0xFFEFF6FF),
  statusAssigned: Color(0xFFEEF2F6),
  statusInProgress: Color(0xFFFFEDD5),
  statusResolved: Color(0xFFD1FAE5),
  statusClosed: Color(0xFFF3F4F6),
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

const priorityColors = <String, Color>{
  'Tinggi': Color(0xFFEF4444),
  'Sedang': Color(0xFFF97316),
  'Rendah': Color(0xFF6B7280),
};

const priorityBgColors = <String, Color>{
  'Tinggi': Color(0xFFFEE2E2),
  'Sedang': Color(0xFFFFEDD5),
  'Rendah': Color(0xFFF3F4F6),
};

const statusFlow = [
  statusOpen,
  statusAssigned,
  statusInProgress,
  statusResolved,
  statusClosed,
];

// ---------------------------------------------------------------------------
// NOTIFICATIONS
// ---------------------------------------------------------------------------

final allNotifications = <NotificationItem>[
  NotificationItem(
    id: 'N-001',
    title: 'Laporan Dalam Proses',
    body: 'Laporan INC-001 (AC ruang kuliah) sedang ditangani oleh tim teknis.',
    timeAgo: '5 menit lalu',
    isUnread: true,
    icon: Icons.engineering_outlined,
    iconColor: const Color(0xFFC2410C),
    incidentId: 'INC-001',
  ),
  NotificationItem(
    id: 'N-002',
    title: 'Laporan Telah Selesai',
    body: 'Laporan INC-004 (Toilet mampet) telah ditandai selesai.',
    timeAgo: '1 jam lalu',
    isUnread: true,
    icon: Icons.check_circle_outline,
    iconColor: const Color(0xFF047857),
    incidentId: 'INC-004',
  ),
  NotificationItem(
    id: 'N-003',
    title: 'Ada Laporan Serupa',
    body: 'Mahasiswa lain melaporkan masalah lampu di Gedung A yang sama.',
    timeAgo: '2 jam lalu',
    isUnread: true,
    icon: Icons.warning_amber_rounded,
    iconColor: const Color(0xFFF97316),
  ),
  NotificationItem(
    id: 'N-004',
    title: 'Status Diperbarui',
    body: 'Laporan INC-002 (Lampu koridor) telah di-assign ke petugas.',
    timeAgo: '5 jam lalu',
    isUnread: false,
    icon: Icons.swap_horiz,
    iconColor: const Color(0xFF3B82F6),
    incidentId: 'INC-002',
  ),
  NotificationItem(
    id: 'N-005',
    title: 'Laporan Dikonfirmasi',
    body: '3 mahasiswa mengkonfirmasi laporan INC-006 (WiFi lambat).',
    timeAgo: '1 hari lalu',
    isUnread: false,
    icon: Icons.people_outline,
    iconColor: const Color(0xFF8B5CF6),
    incidentId: 'INC-006',
  ),
  NotificationItem(
    id: 'N-006',
    title: 'Permintaan Reopen Diterima',
    body: 'Permintaan pembukaan kembali laporan INC-003 telah disetujui.',
    timeAgo: '2 hari lalu',
    isUnread: false,
    icon: Icons.refresh,
    iconColor: const Color(0xFF10B981),
    incidentId: 'INC-003',
  ),
];

// ---------------------------------------------------------------------------
// BUILDINGS
// ---------------------------------------------------------------------------

final allBuildings = <Building>[
  Building(
    name: 'Gedung A',
    floors: [
      Floor(name: 'Lantai 1', areas: ['A101', 'A102', 'A103', 'Koridor', 'Lobi', 'Toilet']),
      Floor(name: 'Lantai 2', areas: ['A201', 'A202', 'A203', 'A204', 'Koridor', 'Toilet']),
      Floor(name: 'Lantai 3', areas: ['A301', 'A302', 'A303', 'Koridor', 'Toilet']),
    ],
  ),
  Building(
    name: 'Gedung B',
    floors: [
      Floor(name: 'Lantai 1', areas: ['B101', 'B102', 'B103', 'Lab Komputer', 'Koridor', 'Toilet']),
      Floor(name: 'Lantai 2', areas: ['B201', 'B202', 'B203', 'B204', 'Koridor', 'Toilet']),
    ],
  ),
  Building(
    name: 'Gedung F',
    floors: [
      Floor(name: 'Lantai 1', areas: ['F101', 'F102', 'F103', 'F104', 'Koridor', 'Lobi', 'Toilet']),
      Floor(name: 'Lantai 2', areas: ['F201', 'F202', 'F203', 'Lab Bahasa', 'Koridor', 'Toilet']),
      Floor(name: 'Lantai 3', areas: ['F301', 'F302', 'F303', 'Aula', 'Koridor', 'Toilet']),
    ],
  ),
  Building(
    name: 'Perpustakaan',
    floors: [
      Floor(name: 'Lantai 1', areas: ['Ruang Baca', 'Lobi', 'Toilet', 'Area Buku']),
      Floor(name: 'Lantai 2', areas: ['Ruang Diskusi', 'Ruang Digital', 'Toilet']),
    ],
  ),
  Building(
    name: 'Gedung Serbaguna',
    floors: [
      Floor(name: 'Lantai 1', areas: ['Aula', 'Kantin', 'Koridor', 'Toilet', 'Mushola']),
      Floor(name: 'Lantai 2', areas: ['Ruang Rapat', 'Ruang Organisasi', 'Koridor', 'Toilet']),
    ],
  ),
  Building(
    name: 'Asrama Putra',
    floors: [
      Floor(name: 'Lantai 1', areas: ['Kamar 101-110', 'Ruang Tamu', 'Toilet', 'Dapur Umum']),
      Floor(name: 'Lantai 2', areas: ['Kamar 201-210', 'Ruang Belajar', 'Toilet', 'Dapur Umum']),
    ],
  ),
  Building(
    name: 'Asrama Putri',
    floors: [
      Floor(name: 'Lantai 1', areas: ['Kamar 101-110', 'Ruang Tamu', 'Toilet', 'Dapur Umum']),
      Floor(name: 'Lantai 2', areas: ['Kamar 201-210', 'Ruang Belajar', 'Toilet', 'Dapur Umum']),
    ],
  ),
  Building(
    name: 'Lokasi Luar Gedung',
    floors: [
      Floor(
        name: 'Area Terbuka',
        areas: ['Taman Kampus', 'Lapangan', 'Parkiran Motor', 'Parkiran Mobil', 'Gazebo', 'Halte', 'Jembatan Penghubung'],
      ),
      Floor(
        name: 'Fasilitas Umum',
        areas: ['Kantin Utama', 'Koperasi', 'Pos Satpam', 'Tempat Duduk Luar', 'Papan Informasi'],
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// CATEGORIES
// ---------------------------------------------------------------------------

final allReportCategories = <ReportCategory>[
  ReportCategory(name: 'AC', icon: Icons.ac_unit, color: Color(0xFF3B82F6)),
  ReportCategory(name: 'Lampu', icon: Icons.lightbulb_outline, color: Color(0xFFFBBF24)),
  ReportCategory(name: 'Listrik', icon: Icons.bolt, color: Color(0xFFF97316)),
  ReportCategory(name: 'Proyektor', icon: Icons.videocam, color: Color(0xFF8B5CF6)),
  ReportCategory(name: 'Pipa Air', icon: Icons.water_drop, color: Color(0xFF06B6D4)),
  ReportCategory(name: 'Toilet', icon: Icons.wc, color: Color(0xFF10B981)),
  ReportCategory(name: 'Furnitur', icon: Icons.chair_outlined, color: Color(0xFFEC4899)),
  ReportCategory(name: 'WiFi', icon: Icons.wifi, color: Color(0xFF6366F1)),
  ReportCategory(name: 'Kebersihan', icon: Icons.cleaning_services, color: Color(0xFF14B8A6)),
  ReportCategory(name: 'Struktur', icon: Icons.construction, color: Color(0xFFEF4444)),
];

// ---------------------------------------------------------------------------
// USER
// ---------------------------------------------------------------------------

const currentUser = User(
  name: 'Andi Mahasiswa',
  role: 'Student',
  email: 'andi.mahasiswa@campus.id',
);

const staffUser = User(
  name: 'Budi Teknisi',
  role: 'Staff',
  email: 'budi.teknisi@campus.id',
);

const appName = 'CIVIC Campus';
const appVersion = '1.0.0';
const appCopyright = '© 2026 CIVIC Campus';

// ---------------------------------------------------------------------------
// REPORT CONFIG
// ---------------------------------------------------------------------------

const reportStepTitles = [
  'Pilih Lokasi',
  'Pilih Kategori',
  'Unggah Foto',
  'Deskripsi',
  'Tinjau & Kirim',
];

const reportStepSubtitles = [
  'Di mana lokasi masalah?',
  'Apa jenis masalahnya?',
  'Ambil atau unggah foto bukti',
  'Tambahkan deskripsi (opsional)',
  'Periksa dan kirim laporan',
];

const reportTotalSteps = 5;

const scoreCategoryMatch = 60;
const scoreBuildingMatch = 20;
const scoreFloorMatch = 20;
const scoreStrongMatchThreshold = 70;

const reportFilters = ['Semua', 'Aktif', 'Selesai'];

const homeCategoryNames = ['Gedung Kuliah', 'Asrama', 'Toilet', 'WiFi'];

const duplicateSuggestions = <DuplicateSuggestion>[
  DuplicateSuggestion(
    title: 'AC Lantai 2 tidak dingin',
    location: 'Gedung F / Lantai 2',
    category: 'AC',
    building: 'Gedung F',
    floor: 'Lantai 2',
    status: statusInProgress,
    confirmCount: 3,
  ),
  DuplicateSuggestion(
    title: 'AC rusak di F101',
    location: 'Gedung F / F101',
    category: 'AC',
    building: 'Gedung F',
    floor: 'Lantai 1',
    status: statusOpen,
    confirmCount: 1,
  ),
];
