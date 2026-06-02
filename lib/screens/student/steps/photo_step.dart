import 'package:flutter/material.dart';

class PhotoStep extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onRemovePhoto;

  const PhotoStep({
    super.key,
    required this.photos,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto bukti (min. 1 foto)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        const Text('Ambil foto kerusakan sebagai bukti. Foto akan dikompresi otomatis.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5)),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == photos.length) return _buildAddButton();
              return _buildPhotoItem(index);
            },
          ),
        ),
        if (photos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('Belum ada foto. Ketuk + untuk menambah.',
                style: TextStyle(fontSize: 12, color: const Color(0xFF9CA3AF), fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onAddPhoto,
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 32, color: Color(0xFF9CA3AF)),
              SizedBox(height: 6),
              Text('Tambah Foto',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    return Stack(
      children: [
        Container(
          width: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image, size: 36, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Foto ${index + 1}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            tooltip: 'Hapus foto',
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: const CircleBorder(),
              minimumSize: const Size(36, 36),
            ),
            onPressed: () => onRemovePhoto(index),
            icon: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class PhotoPickerSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const PhotoPickerSheet({super.key, required this.onCamera, required this.onGallery});

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
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Tambah Foto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF1D4ED8)),
              ),
              title: const Text('Kamera'),
              subtitle: const Text('Ambil foto langsung'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () { Navigator.of(context).pop(); onCamera(); },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.photo_library_outlined, color: Color(0xFF374151)),
              ),
              title: const Text('Galeri'),
              subtitle: const Text('Pilih dari galeri'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () { Navigator.of(context).pop(); onGallery(); },
            ),
          ],
        ),
      ),
    );
  }
}
