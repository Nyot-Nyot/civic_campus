import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../data/models/building.dart';

class LocationStep extends StatelessWidget {
  final String? selectedBuilding;
  final String? selectedFloor;
  final String? selectedArea;
  final TextEditingController searchController;
  final TextEditingController detailsController;
  final ValueChanged<String> onBuildingSelected;
  final ValueChanged<String> onFloorSelected;
  final ValueChanged<String> onAreaSelected;
  final VoidCallback onClearArea;
  final VoidCallback onSearchChanged;

  const LocationStep({
    super.key,
    required this.selectedBuilding,
    required this.selectedFloor,
    required this.selectedArea,
    required this.searchController,
    required this.detailsController,
    required this.onBuildingSelected,
    required this.onFloorSelected,
    required this.onAreaSelected,
    required this.onClearArea,
    required this.onSearchChanged,
  });

  Floor? get _currentFloor {
    if (selectedBuilding == null || selectedFloor == null) return null;
    final building = allBuildings.firstWhere((b) => b.name == selectedBuilding, orElse: () => const Building(name: '', floors: []));
    return building.floors.firstWhere((f) => f.name == selectedFloor, orElse: () => const Floor(name: '', areas: []));
  }

  List<Building> get _filteredBuildings {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return allBuildings;
    return allBuildings.where((b) {
      if (b.name.toLowerCase().contains(query)) return true;
      for (final f in b.floors) {
        if (f.name.toLowerCase().contains(query)) return true;
        for (final a in f.areas) {
          if (a.toLowerCase().contains(query)) return true;
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Cari gedung, lantai, atau ruangan...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged();
                    },
                  )
                : null,
          ),
          onChanged: (_) => onSearchChanged(),
        ),
        const SizedBox(height: 20),
        if (selectedArea != null && selectedFloor != null && selectedBuilding != null) ...[
          _buildLocationPath(),
          const SizedBox(height: 20),
        ],
        if (selectedBuilding == null)
          _ChipSection(
            title: 'Pilih Gedung / Area',
            chips: _filteredBuildings.map((b) => b.name).toList(),
            selected: null,
            onSelect: (v) {
              onBuildingSelected(v);
              searchController.clear();
              onSearchChanged();
            },
          ),
        if (selectedBuilding != null && selectedFloor == null)
          _ChipSection(
            title: 'Pilih Lantai',
            hint: selectedBuilding == 'Lokasi Luar Gedung' ? 'Pilih kategori area luar' : null,
            chips: allBuildings
                .firstWhere((b) => b.name == selectedBuilding, orElse: () => const Building(name: '', floors: []))
                .floors
                .map((f) => f.name)
                .toList(),
            selected: null,
            onSelect: onFloorSelected,
          ),
        if (selectedFloor != null && selectedArea == null)
          _ChipSection(
            title: 'Pilih Ruangan / Area',
            chips: _currentFloor?.areas ?? [],
            selected: null,
            onSelect: onAreaSelected,
          ),
        if (selectedArea != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onClearArea,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Ubah pilihan lokasi'),
          ),
          const SizedBox(height: 16),
          const Text('Detail lokasi tambahan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
          const SizedBox(height: 8),
          TextField(
            controller: detailsController,
            decoration: const InputDecoration(
              hintText: 'Contoh: di sebelah pintu masuk, dekat jendela...',
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
            ),
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  Widget _buildLocationPath() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 18, color: Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$selectedBuilding › $selectedFloor › $selectedArea',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  final String title;
  final String? hint;
  final List<String> chips;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _ChipSection({
    required this.title,
    this.hint,
    required this.chips,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(hint!, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
        const SizedBox(height: 10),
        if (chips.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Tidak ada hasil',
                style: TextStyle(color: Color(0xFF9CA3AF), fontStyle: FontStyle.italic)),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: chips.map((chip) {
              final isSel = chip == selected;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onSelect(chip),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF111827) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(chip,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSel ? Colors.white : const Color(0xFF111827))),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
