import 'package:flutter/material.dart';

import 'photo_source_tile.dart';

class PhotoPickerSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final String title;

  const PhotoPickerSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
    this.title = 'Tambah Bukti Foto',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            PhotoSourceTile(
              icon: Icons.camera_alt_outlined,
              title: 'Ambil Foto',
              subtitle: 'Gunakan kamera untuk mengambil foto',
              onTap: onCamera,
            ),
            const SizedBox(height: 12),
            PhotoSourceTile(
              icon: Icons.photo_library_outlined,
              title: 'Pilih dari Galeri',
              subtitle: 'Pilih foto yang sudah ada',
              onTap: onGallery,
            ),
          ],
        ),
      ),
    );
  }
}
