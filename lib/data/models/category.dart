import 'package:flutter/material.dart';

class ReportCategory {
  final String name;
  final IconData icon;
  final Color color;
  const ReportCategory({required this.name, required this.icon, required this.color});

  ReportCategory copyWith({String? name, IconData? icon, Color? color}) {
    return ReportCategory(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
