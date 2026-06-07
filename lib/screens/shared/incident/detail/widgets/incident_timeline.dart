import 'package:flutter/material.dart';

class IncidentTimeline extends StatelessWidget {
  final String currentStatus;
  final List<String> statusFlow;
  final Map<String, Color> statusColors;
  final Map<String, Color> statusBgColors;

  const IncidentTimeline({
    super.key,
    required this.currentStatus,
    required this.statusFlow,
    required this.statusColors,
    required this.statusBgColors,
  });

  static const Map<String, String> statusLabelsIndonesian = {
    'Open': 'Menunggu Penanganan',
    'Assigned': 'Sudah Ditugaskan',
    'Menunggu Anggaran': 'Menunggu Anggaran',
    'In Progress': 'Sedang Dikerjakan',
    'Resolved': 'Selesai Dikerjakan',
    'Closed': 'Ditutup',
  };

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        statusFlow.indexOf(currentStatus).clamp(0, statusFlow.length - 1);

    return Column(
      children: List.generate(statusFlow.length, (index) {
        final status = statusFlow[index];
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;
        final isPending = index > currentIndex;

        final statusColor = statusColors[status] ?? const Color(0xFF6B7280);
        final statusBg = statusBgColors[status] ?? const Color(0xFFF3F4F6);
        final displayLabel = statusLabelsIndonesian[status] ?? status;

        Color circleColor;
        Widget? circleChild;

        if (isCompleted) {
          circleColor = statusColor;
          circleChild = const Icon(Icons.check, size: 9, color: Colors.white);
        } else if (isCurrent) {
          circleColor = statusColor;
          circleChild = Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          );
        } else {
          circleColor = const Color(0xFFE5E7EB);
          circleChild = null;
        }

        final connectorHeight = index < statusFlow.length - 1 ? 24.0 : 0.0;

        return SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: circleColor.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: circleChild,
                    ),
                    if (connectorHeight > 0)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isPending
                              ? const Color(0xFFE5E7EB)
                              : circleColor.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrent ? statusBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          displayLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCompleted
                                ? const Color(0xFF374151)
                                : isCurrent
                                    ? statusColor
                                    : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
