import 'package:flutter/material.dart';

class IconPickerGrid extends StatelessWidget {
  final IconData selectedIcon;
  final ValueChanged<IconData> onSelected;
  final Color highlightColor;

  static const icons = <IconData>[
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

  const IconPickerGrid({
    super.key,
    required this.selectedIcon,
    required this.onSelected,
    this.highlightColor = const Color(0xFF3B82F6),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: icons.length,
        itemBuilder: (context, i) {
          final icon = icons[i];
          final isSelected = icon == selectedIcon;
          return GestureDetector(
            onTap: () => onSelected(icon),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? highlightColor.withValues(alpha: 0.15)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: highlightColor, width: 2)
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? highlightColor : const Color(0xFF6B7280),
                size: 18,
              ),
            ),
          );
        },
      ),
    );
  }
}
