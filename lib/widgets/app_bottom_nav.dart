import 'package:flutter/material.dart';

class AppBottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String? label;
  final bool showBadge;

  const AppBottomNavItem({
    required this.icon,
    required this.selectedIcon,
    this.label,
    this.showBadge = false,
  });
}

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<AppBottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(42),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.18),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              final icon = selected ? item.selectedIcon : item.icon;
              return Expanded(
                child: Tooltip(
                  message: item.label ?? '',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(34),
                    onTap: () => onItemSelected(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Semantics(
                        label: item.label,
                        button: true,
                        selected: selected,
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                width: selected ? 60 : 44,
                                height: selected ? 60 : 44,
                                decoration: selected
                                    ? const BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                      )
                                    : null,
                                child: Icon(
                                  icon,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                  size: selected ? 28 : 24,
                                ),
                              ),
                              if (item.showBadge)
                                Positioned(
                                  top: selected ? 4 : 0,
                                  right: selected ? 4 : 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
