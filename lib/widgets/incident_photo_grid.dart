import 'package:flutter/material.dart';

class IncidentPhotoGrid extends StatelessWidget {
  final int photoCount;

  const IncidentPhotoGrid({super.key, required this.photoCount});

  @override
  Widget build(BuildContext context) {
    if (photoCount == 0) {
      return const Text(
        'Tidak ada foto bukti.',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: photoCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined,
                  size: 28, color: Color(0xFFD1D5DB)),
              SizedBox(height: 4),
              Text(
                'Foto',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
