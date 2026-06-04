import 'package:flutter/material.dart';

import 'package:civic_campus/data/providers/location_provider.dart';

void showBuildingSheet({
  required BuildContext context,
  required LocationProvider provider,
  String? buildingId,
  String? buildingName,
  List<Map<String, dynamic>>? existingFloors,
  required VoidCallback onDataChanged,
}) {
  final isEditing = buildingId != null;
  final nameController = TextEditingController(text: buildingName ?? '');
  final floorNames = <TextEditingController>[];
  final floorAreas = <TextEditingController>[];

  if (isEditing && existingFloors != null) {
    for (final f in existingFloors) {
      floorNames.add(TextEditingController(text: f['name'] as String? ?? ''));
      final areasList = (f['areas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .join(', ') ??
          '';
      floorAreas.add(TextEditingController(text: areasList));
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
                            await provider.delete(buildingId);
                            if (!context.mounted) return;
                            Navigator.pop(ctx);
                            onDataChanged();
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

                          if (isEditing) {
                            await provider.update(buildingId, {
                              'name': name,
                              'type': 'Building',
                            });
                            if (!context.mounted) return;
                            Navigator.pop(ctx);
                            onDataChanged();
                            return;
                          }

                          final err = await provider.create({
                            'name': name,
                            'type': 'Building',
                          });
                          if (err != null) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal membuat gedung.')),
                            );
                            return;
                          }
                          if (!context.mounted) return;
                          Navigator.pop(ctx);
                          onDataChanged();
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
