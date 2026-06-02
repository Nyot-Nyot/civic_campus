import 'package:flutter/material.dart';

import '../../../data/models/building.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/building_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../widgets/state_views.dart';

class AdminMasterDataTab extends StatefulWidget {
  const AdminMasterDataTab({super.key});

  @override
  State<AdminMasterDataTab> createState() => _AdminMasterDataTabState();
}

class _AdminMasterDataTabState extends State<AdminMasterDataTab> {
  final _buildingRepo = BuildingRepository();
  final _categoryRepo = CategoryRepository();
  List<Building> _buildings = [];
  List<ReportCategory> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;
  int? _expandedBuilding;

  static const _iconOptions = <IconData>[
    Icons.ac_unit,
    Icons.lightbulb_outline,
    Icons.bolt,
    Icons.videocam,
    Icons.water_drop,
    Icons.wc,
    Icons.chair_outlined,
    Icons.wifi,
    Icons.cleaning_services,
    Icons.construction,
    Icons.electrical_services,
    Icons.pets,
    Icons.door_front_door_outlined,
    Icons.window,
    Icons.format_paint,
    Icons.coffee,
    Icons.fence,
    Icons.roofing,
    Icons.downhill_skiing,
    Icons.sensor_door,
  ];

  static const _colorOptions = <Color>[
    Color(0xFF3B82F6),
    Color(0xFFFBBF24),
    Color(0xFFF97316),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF6366F1),
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
    Color(0xFF78716C),
    Color(0xFF1C1917),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    try {
      final b = await _buildingRepo.getAll();
      final c = await _categoryRepo.getAll();
      if (!mounted) return;
      setState(() {
        _buildings = b;
        _categories = c;
      });
    } catch (e) {
      debugPrint('AdminMasterDataTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBuilding(int index) async {
    final name = _buildings[index].name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Lokasi'),
        content: Text('Hapus "$name" dan semua lantai di dalamnya?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _buildingRepo.delete(index);
      if (!mounted) return;
      if (_expandedBuilding == index) _expandedBuilding = null;
      _load();
    }
  }

  void _showBuildingSheet(BuildContext context, {int? index, Building? building}) {
    final isEditing = building != null;
    final nameController = TextEditingController(text: building?.name ?? '');
    final floorNames = <TextEditingController>[];
    final floorAreas = <TextEditingController>[];

    if (isEditing) {
      for (final f in building.floors) {
        floorNames.add(TextEditingController(text: f.name));
        floorAreas.add(TextEditingController(text: f.areas.join(', ')));
      }
    } else {
      floorNames.add(TextEditingController());
      floorAreas.add(TextEditingController());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Lokasi' : 'Tambah Lokasi',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Gedung',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Lantai',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setSheetState(() {
                            floorNames.add(TextEditingController());
                            floorAreas.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah Lantai'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView(
                      shrinkWrap: true,
                      children: List.generate(floorNames.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: i == floorNames.length - 1 ? 0 : 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: floorNames[i],
                                  decoration: InputDecoration(
                                    labelText: 'Nama Lantai',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: floorAreas[i],
                                  decoration: InputDecoration(
                                    labelText: 'Ruangan (koma)',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (floorNames.length > 1)
                                IconButton(
                                  onPressed: () => setSheetState(() {
                                    floorNames[i].dispose();
                                    floorAreas[i].dispose();
                                    floorNames.removeAt(i);
                                    floorAreas.removeAt(i);
                                  }),
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  color: const Color(0xFFEF4444),
                                  visualDensity: VisualDensity.compact,
                                )
                              else
                                const SizedBox(width: 48),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (isEditing)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await _buildingRepo.delete(index!);
                              if (!mounted) return;
                              Navigator.pop(ctx);
                              _load();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                            child: const Text('Hapus'),
                          ),
                        ),
                      if (isEditing) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            final floors = <Floor>[];
                            for (var i = 0; i < floorNames.length; i++) {
                              final fn = floorNames[i].text.trim();
                              if (fn.isEmpty) continue;
                              final areas = floorAreas[i].text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                              floors.add(Floor(name: fn, areas: areas));
                            }
                            if (floors.isEmpty) return;
                            final newBuilding = Building(name: name, floors: floors);
                            if (isEditing) {
                              await _buildingRepo.update(index!, newBuilding);
                            } else {
                              await _buildingRepo.add(newBuilding);
                            }
                            if (!mounted) return;
                            Navigator.pop(ctx);
                            _load();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111827),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: Text(isEditing ? 'Simpan' : 'Tambah'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      for (final c in floorNames) { c.dispose(); }
      for (final c in floorAreas) { c.dispose(); }
    });
  }

  void _showCategorySheet(BuildContext context, {int? index, ReportCategory? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    var selectedIcon = category?.icon ?? _iconOptions.first;
    var selectedColor = category?.color ?? _colorOptions.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Kategori' : 'Tambah Kategori',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Kategori',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Ikon',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 10,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: _iconOptions.length,
                      itemBuilder: (ctx, i) {
                        final icon = _iconOptions[i];
                        final isSelected = icon == selectedIcon;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedColor.withValues(alpha: 0.15)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(color: selectedColor, width: 2)
                                  : null,
                            ),
                            child: Icon(icon, color: isSelected ? selectedColor : const Color(0xFF6B7280), size: 18),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Warna',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((c) {
                      final isSelected = c == selectedColor;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 6)]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (isEditing)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await _categoryRepo.delete(index!);
                              if (!mounted) return;
                              Navigator.pop(ctx);
                              _load();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                            child: const Text('Hapus'),
                          ),
                        ),
                      if (isEditing) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            final newCat = ReportCategory(name: name, icon: selectedIcon, color: selectedColor);
                            if (isEditing) {
                              await _categoryRepo.update(index!, newCat);
                            } else {
                              await _categoryRepo.add(newCat);
                            }
                            if (!mounted) return;
                            Navigator.pop(ctx);
                            _load();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111827),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: Text(isEditing ? 'Simpan' : 'Tambah'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => nameController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();
    if (_hasError) return ErrorView(message: 'Gagal memuat master data.', onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const Text('Master Data',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 8),
          const Text('Lokasi dan kategori insiden.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5)),
          const SizedBox(height: 28),
          Row(
            children: [
              const Text('Lokasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showBuildingSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(_buildings.length, (index) {
            final building = _buildings[index];
            final isExpanded = _expandedBuilding == index;
            return Padding(
              padding: EdgeInsets.only(bottom: index == _buildings.length - 1 ? 0 : 8),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() {
                          _expandedBuilding = isExpanded ? null : index;
                        }),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.business, color: Color(0xFF3B82F6), size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                building.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: const Color(0xFF9CA3AF),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        ...List.generate(building.floors.length, (fIndex) {
                          final floor = building.floors[fIndex];
                          final isLast = fIndex == building.floors.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(floor.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Text(
                                    floor.areas.join(', '),
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showBuildingSheet(context, index: index, building: building),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF3B82F6),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => _deleteBuilding(index),
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Hapus'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          Row(
            children: [
              const Text('Kategori',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showCategorySheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return GestureDetector(
                onTap: () => _showCategorySheet(context, index: index, category: cat),
                child: Container(
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, color: cat.color, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cat.color),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
