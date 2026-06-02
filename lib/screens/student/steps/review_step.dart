import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../data/models/incident.dart';

class ReviewStep extends StatelessWidget {
  final String? selectedBuilding;
  final String? selectedFloor;
  final String? selectedArea;
  final String? selectedCategory;
  final TextEditingController detailsController;
  final TextEditingController descriptionController;
  final int photoCount;
  final bool duplicateChecked;
  final String? duplicateAction;
  final VoidCallback onCheckDuplicates;
  final ValueChanged<String> onDuplicateAction;

  const ReviewStep({
    super.key,
    required this.selectedBuilding,
    required this.selectedFloor,
    required this.selectedArea,
    required this.selectedCategory,
    required this.detailsController,
    required this.descriptionController,
    required this.photoCount,
    required this.duplicateChecked,
    required this.duplicateAction,
    required this.onCheckDuplicates,
    required this.onDuplicateAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(
          building: selectedBuilding,
          floor: selectedFloor,
          area: selectedArea,
          details: detailsController.text,
          category: selectedCategory,
          photoCount: photoCount,
          description: descriptionController.text,
        ),
        const SizedBox(height: 24),
        if (!duplicateChecked) ...[
          const Text('Pemeriksaan Duplikat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 8),
          const Text(
              'Sistem akan memeriksa apakah masalah serupa sudah dilaporkan.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCheckDuplicates,
              icon: const Icon(Icons.search, size: 20),
              label: const Text('Periksa Sekarang'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
        ],
        if (duplicateChecked) ...[
          const Text('Hasil Pemeriksaan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          _DuplicateSuggestions(
            selectedCategory: selectedCategory,
            selectedBuilding: selectedBuilding,
            selectedFloor: selectedFloor,
          ),
          const SizedBox(height: 20),
          _ConfirmRadio(
            duplicateAction: duplicateAction,
            onChanged: onDuplicateAction,
          ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String? building, floor, area, details, category, description;
  final int photoCount;

  const _SummaryCard({
    required this.building,
    required this.floor,
    required this.area,
    required this.details,
    required this.category,
    required this.photoCount,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan Laporan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(height: 16),
            _buildRow(Icons.location_on, 'Lokasi', '$building / $floor / $area'),
            if (details != null && details!.isNotEmpty)
              _buildRow(Icons.edit_location, 'Detail Lokasi', details!),
            const SizedBox(height: 10),
            _buildRow(Icons.category, 'Kategori', category ?? ''),
            const SizedBox(height: 10),
            _buildRow(Icons.photo_library, 'Foto', '$photoCount foto'),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildRow(Icons.description, 'Deskripsi', description!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: Color(0xFF111827), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _DuplicateSuggestions extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedBuilding;
  final String? selectedFloor;

  const _DuplicateSuggestions({
    required this.selectedCategory,
    required this.selectedBuilding,
    required this.selectedFloor,
  });

  int _computeMatchScore(String category, String? building, String? floor) {
    int score = 0;
    if (selectedCategory == category) score += scoreCategoryMatch;
    if (selectedBuilding != null && selectedBuilding == building) score += scoreBuildingMatch;
    if (selectedFloor != null && selectedFloor == floor) score += scoreFloorMatch;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final scored = duplicateSuggestions
        .map((s) => (suggestion: s, score: _computeMatchScore(s.category, s.building, s.floor)))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF97316), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Kami menemukan masalah serupa',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...scored.map((item) {
          final s = item.suggestion;
          final score = item.score;
          final isStrong = score >= scoreStrongMatchThreshold;
          return Padding(
            padding: EdgeInsets.only(bottom: s != scored.last.suggestion ? 10 : 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isStrong ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(s.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isStrong ? const Color(0xFFFFEDD5) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(isStrong ? 'Sangat Mirip' : 'Mirip',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isStrong ? const Color(0xFFC2410C) : const Color(0xFF6B7280))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.image_outlined, size: 18, color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 4),
                                Text(s.location,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: s.status == statusInProgress
                                        ? const Color(0xFFFFEDD5)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(s.status,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: s.status == statusInProgress
                                              ? const Color(0xFFC2410C)
                                              : const Color(0xFF1D4ED8))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.people, size: 12, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 4),
                                Text('Dikonfirmasi ${s.confirmCount} mahasiswa',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ConfirmRadio extends StatelessWidget {
  final String? duplicateAction;
  final ValueChanged<String> onChanged;

  const _ConfirmRadio({required this.duplicateAction, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RadioOption(
          value: 'confirm',
          selected: duplicateAction == 'confirm',
          title: 'Ini masalah yang sama',
          subtitle: 'Tambah konfirmasi dan ikuti perkembangan insiden',
          icon: Icons.verified_outlined,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        _RadioOption(
          value: 'new',
          selected: duplicateAction == 'new',
          title: 'Buat laporan baru',
          subtitle: 'Masalah ini berbeda dan perlu insiden baru',
          icon: Icons.add_circle_outline,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String value;
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _RadioOption({
    required this.value,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF3F4F6) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? const Color(0xFF111827) : const Color(0xFF9CA3AF), size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected ? const Color(0xFF111827) : const Color(0xFF6B7280))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                  color: selected ? const Color(0xFF111827) : Colors.transparent,
                ),
                child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
