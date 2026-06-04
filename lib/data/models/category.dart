import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class ReportCategory {
  final String name;
  final IconData icon;
  final Color color;
  const ReportCategory({required this.name, required this.icon, required this.color});

  factory ReportCategory.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    return ReportCategory(
      name: name,
      icon: categoryIcons[name] ?? Icons.category,
      color: categoryColors[name] ?? Colors.grey,
    );
  }

  ReportCategory copyWith({String? name, IconData? icon, Color? color}) {
    return ReportCategory(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
