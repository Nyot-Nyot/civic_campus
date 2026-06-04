import 'package:flutter/material.dart';

import 'package:civic_campus/data/providers/category_provider.dart';
import 'package:civic_campus/screens/admin/widgets/color_picker_grid.dart';
import 'package:civic_campus/screens/admin/widgets/icon_picker_grid.dart';

void showCategorySheet({
  required BuildContext context,
  required CategoryProvider provider,
  String? categoryId,
  String? categoryName,
  IconData? categoryIcon,
  Color? categoryColor,
  required VoidCallback onDataChanged,
}) {
  final isEditing = categoryId != null;
  final nameController = TextEditingController(text: categoryName ?? '');
  var selectedIcon = categoryIcon ?? IconPickerGrid.icons.first;
  var selectedColor = categoryColor ?? ColorPickerGrid.colors.first;

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
                IconPickerGrid(
                  selectedIcon: selectedIcon,
                  highlightColor: selectedColor,
                  onSelected: (icon) => setSheetState(() => selectedIcon = icon),
                ),
                const SizedBox(height: 16),
                const Text('Warna',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                const SizedBox(height: 10),
                ColorPickerGrid(
                  selectedColor: selectedColor,
                  onSelected: (c) => setSheetState(() => selectedColor = c),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (isEditing)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await provider.delete(categoryId);
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
                          final colorHex = '#${selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
                          if (isEditing) {
                            await provider.update(categoryId, {
                              'name': name,
                              'color_hex': colorHex,
                            });
                          } else {
                            await provider.create({
                              'name': name,
                              'color_hex': colorHex,
                            });
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
  ).whenComplete(() => nameController.dispose());
}
