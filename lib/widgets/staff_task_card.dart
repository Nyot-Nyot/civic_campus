import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/dummy_data.dart';

class StaffTaskCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onTap;

  const StaffTaskCard({
    super.key,
    required this.incident,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = statusColors[incident.status] ?? const Color(0xFF6B7280);
    final statusBg = statusBgColors[incident.status] ?? const Color(0xFFF3F4F6);
    final categoryIcon = categoryIcons[incident.category] ?? Icons.help_outline;
    final categoryColor = categoryColors[incident.category] ?? const Color(0xFF9CA3AF);
    final prioColor = priorityColors[incident.priority] ?? const Color(0xFF6B7280);
    final prioBg = priorityBgColors[incident.priority] ?? const Color(0xFFF3F4F6);

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 22),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: prioColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: prioBg, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              incident.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              incident.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              incident.location,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Tooltip(
                            message: incident.isOverdue() ? 'Terlambat' : '',
                            child: Semantics(
                              label: incident.isOverdue() ? 'Laporan terlambat' : '',
                              child: Icon(
                                Icons.access_time,
                                size: 12,
                                color: incident.isOverdue()
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            incident.isOverdue()
                                ? '${incident.timeAgo} (terlambat)'
                                : incident.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: incident.isOverdue()
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF9CA3AF),
                              fontWeight: incident.isOverdue() ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          if (incident.confirmationCount > 0) ...[
                            const SizedBox(width: 14),
                            const Icon(Icons.people, size: 12, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Text(
                              '+${incident.confirmationCount}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      _StatusDots(currentStatus: incident.status),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 20, color: Color(0xFFD1D5DB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDots extends StatelessWidget {
  final String currentStatus;

  const _StatusDots({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final currentIdx = statusFlow.indexOf(currentStatus).clamp(0, statusFlow.length - 1);
    return Row(
      children: List.generate(statusFlow.length, (index) {
        final isCompleted = index < currentIdx;
        final isCurrent = index == currentIdx;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: index < statusFlow.length - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF047857)
                  : isCurrent
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
