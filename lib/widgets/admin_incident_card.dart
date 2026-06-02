import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/constants/app_constants.dart';

class AdminIncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onTap;
  final VoidCallback? onAssign;

  const AdminIncidentCard({
    super.key,
    required this.incident,
    this.onTap,
    this.onAssign,
  });

  static const _statusLabels = {
    statusOpen: 'Menunggu Penanganan',
    statusAssigned: 'Sudah Ditugaskan',
    statusInProgress: 'Sedang Dikerjakan',
    statusResolved: 'Selesai Dikerjakan',
    statusClosed: 'Ditutup',
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = statusColors[incident.status] ?? const Color(0xFF6B7280);
    final statusBg = statusBgColors[incident.status] ?? const Color(0xFFF3F4F6);
    final categoryIcon = categoryIcons[incident.category] ?? Icons.help_outline;
    final categoryColor = categoryColors[incident.category] ?? const Color(0xFF9CA3AF);
    final prioColor = priorityColors[incident.priority] ?? const Color(0xFF6B7280);
    final prioBg = priorityBgColors[incident.priority] ?? const Color(0xFFF3F4F6);

    final canAssign = incident.status == statusOpen && onAssign != null;

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
                              _statusLabels[incident.status] ?? incident.status,
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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 12, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            '${incident.confirmationCount} konfirmasi',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                          if (incident.assignedTo != null) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.person, size: 12, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(
                                incident.assignedTo!,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (canAssign) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: onAssign,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1,
                                  size: 16,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
