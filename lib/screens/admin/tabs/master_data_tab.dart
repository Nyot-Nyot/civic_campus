import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/models/category.dart';
import 'package:civic_campus/data/providers/location_provider.dart';
import 'package:civic_campus/data/providers/category_provider.dart';
import 'package:civic_campus/widgets/state_views.dart';
import 'package:civic_campus/screens/admin/tabs/master_data_building_sheet.dart';
import 'package:civic_campus/screens/admin/tabs/master_data_category_sheet.dart';

class _BuildingTree {
  final String id;
  final String name;
  final List<_FloorTree> floors;
  _BuildingTree({required this.id, required this.name, required this.floors});
}

class _FloorTree {
  final String id;
  final String name;
  final List<String> areas;
  _FloorTree({required this.id, required this.name, required this.areas});
}

class AdminMasterDataTab extends StatefulWidget {
  const AdminMasterDataTab({super.key});

  @override
  State<AdminMasterDataTab> createState() => _AdminMasterDataTabState();
}

class _AdminMasterDataTabState extends State<AdminMasterDataTab> {
  List<_BuildingTree> _buildings = [];
  List<ReportCategory> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;
  int? _expandedBuilding;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    try {
      final locProvider = context.read<LocationProvider>();
      final catProvider = context.read<CategoryProvider>();
      await Future.wait([
        locProvider.loadBuildings(),
        catProvider.load(),
      ]);
      if (!mounted) return;
      final buildingMaps = List<Map<String, dynamic>>.from(locProvider.buildings);
      final buildings = <_BuildingTree>[];
      for (final bMap in buildingMaps) {
        final bid = bMap['id'] as String;
        final bName = bMap['name'] as String? ?? '';
        await locProvider.selectBuilding(bMap);
        final floorMaps = List<Map<String, dynamic>>.from(locProvider.floors);
        final floors = <_FloorTree>[];
        for (final fMap in floorMaps) {
          final fid = fMap['id'] as String;
          final fName = fMap['name'] as String? ?? '';
          await locProvider.selectFloor(fMap);
          final areas = locProvider.areas
              .map((a) => a['name'] as String? ?? '')
              .toList();
          floors.add(_FloorTree(id: fid, name: fName, areas: areas));
        }
        buildings.add(_BuildingTree(id: bid, name: bName, floors: floors));
      }
      final catMaps = catProvider.categories;
      final categories =
          catMaps.map((m) => ReportCategory.fromJson(m)).toList();
      if (!mounted) return;
      setState(() {
        _buildings = buildings;
        _categories = categories;
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
      final provider = context.read<LocationProvider>();
      await provider.delete(_buildings[index].id);
      if (!mounted) return;
      if (_expandedBuilding == index) _expandedBuilding = null;
      _load();
    }
  }

  void _showBuildingSheet({int? index, _BuildingTree? building}) {
    showBuildingSheet(
      context: context,
      provider: context.read<LocationProvider>(),
      buildingId: building?.id,
      buildingName: building?.name,
      existingFloors: building?.floors.map((f) => {
        'name': f.name,
        'areas': f.areas,
      }).toList(),
      onDataChanged: _load,
    );
  }

  void _showCategorySheet({int? index, ReportCategory? category}) {
    showCategorySheet(
      context: context,
      provider: context.read<CategoryProvider>(),
      categoryId: index != null && category != null
          ? '$index'
          : null,
      categoryName: category?.name,
      categoryIcon: category?.icon,
      categoryColor: category?.color,
      onDataChanged: _load,
    );
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
                onPressed: () => _showBuildingSheet(),
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
                              onPressed: () => _showBuildingSheet(index: index, building: building),
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
                onPressed: () => _showCategorySheet(),
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
                onTap: () => _showCategorySheet(index: index, category: cat),
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
