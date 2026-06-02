import 'package:flutter/material.dart';

class DescriptionStep extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deskripsi masalah (opsional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        const SizedBox(height: 8),
        const Text('Jelaskan masalah yang Anda lihat agar petugas lebih mudah memahami.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5)),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Contoh: AC tidak mengeluarkan udara dingin sama sekali, sudah dicek remote dan baterai...',
            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
          ),
          maxLines: 6,
          maxLength: 500,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 20),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Deskripsi yang jelas membantu petugas menyiapkan peralatan yang tepat.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
