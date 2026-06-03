import 'package:flutter/material.dart';

class ColorPickerGrid extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onSelected;

  static const colors = <Color>[
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

  const ColorPickerGrid({super.key, required this.selectedColor, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((c) {
        final isSelected = c == selectedColor;
        return GestureDetector(
          onTap: () => onSelected(c),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 6)]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
