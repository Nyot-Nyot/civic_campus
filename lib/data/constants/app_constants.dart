import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// STATUS CONSTANTS (defined in models/incident.dart)
// ---------------------------------------------------------------------------

const statusColors = <String, Color>{
  'Open': Color(0xFF1D4ED8),
  'Assigned': Color(0xFF374151),
  'Menunggu Anggaran': Color(0xFFB45309),
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
  'Menunggu Anggaran': Color(0xFFFFFBEB),
};

const statusFlow = [
  'Open',
  'Assigned',
  'Menunggu Anggaran',
  'In Progress',
  'Resolved',
  'Closed',
];

// ---------------------------------------------------------------------------
// CATEGORY CONSTANTS
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// PRIORITY CONSTANTS
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// APP INFO
// ---------------------------------------------------------------------------

const appName = 'CIVIC Campus';
const appVersion = '1.0.0';
const appCopyright = '© 2026 CIVIC Campus';
