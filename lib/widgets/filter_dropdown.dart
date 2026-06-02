import 'package:flutter/material.dart';

import '../data/dummy_data.dart';

class FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Widget? icon;
  final ValueChanged<String> onSelected;

  const FilterDropdown({super.key,
    required this.label,
    required this.value,
    required this.items,
    this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = value ?? label;
    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (ctx) => [
        for (final item in items)
          PopupMenuItem(
            value: item,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item != 'Semua' && label == 'Prioritas')
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: priorityColors[item] ?? const Color(0xFF6B7280),
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  item == 'Semua' ? 'Semua $label' : item,
                  style: TextStyle(
                    fontWeight: value == item ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: value != null ? const Color(0xFF111827) : const Color(0xFFD1D5DB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: value != null ? FontWeight.w600 : FontWeight.w500,
                  color: value != null ? const Color(0xFF111827) : const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
