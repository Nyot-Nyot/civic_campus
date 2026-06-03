import 'package:flutter/material.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/constants/app_constants.dart';

enum IncidentCardVariant { compact, detailed }

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onTap;
  final IncidentCardVariant variant;

  const IncidentCard({
    super.key,
    required this.incident,
    this.onTap,
    this.variant = IncidentCardVariant.detailed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: variant == IncidentCardVariant.compact
                ? _buildCompactLayout()
                : _buildDetailedLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(incident.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(incident.location,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatusBadge(status: incident.status),
                  const SizedBox(width: 10),
                  Text(incident.timeAgo,
                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _CategoryIcon(category: incident.category, size: 40, borderRadius: 12),
      ],
    );
  }

  Widget _buildDetailedLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryIcon(category: incident.category, size: 44, borderRadius: 14),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(incident.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: incident.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(incident.location,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 12, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(incident.timeAgo,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  if (incident.confirmationCount > 0) ...[
                    const SizedBox(width: 14),
                    const Icon(Icons.people, size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text('+${incident.confirmationCount}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                  if (incident.photoCount > 1) ...[
                    const SizedBox(width: 14),
                    const Icon(Icons.photo_library, size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text('${incident.photoCount}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 20, color: Color(0xFFD1D5DB)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColors[status] ?? const Color(0xFF1D4ED8);
    final bg = statusBgColors[status] ?? const Color(0xFFEFF6FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String category;
  final double size;
  final double borderRadius;

  const _CategoryIcon({
    required this.category,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final icon = categoryIcons[category] ?? Icons.report_problem;
    final color = categoryColors[category] ?? const Color(0xFF3B82F6);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
