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

        Color circleColor;
        IconData? icon;
        if (isCompleted) {
          circleColor = const Color(0xFF047857);
          icon = Icons.check;
        } else if (isCurrent) {
          circleColor = const Color(0xFF1D4ED8);
          icon = Icons.circle;
        } else {
          circleColor = const Color(0xFFE5E7EB);
          icon = null;
        }

        final statusColorStatus =
            statusColors[status] ?? const Color(0xFF6B7280);
        final statusBgStatus =
            statusBgColors[status] ?? const Color(0xFFF3F4F6);

        final connectorHeight = index < statusFlow.length - 1 ? 20.0 : 0.0;

        return SizedBox(
          height: 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: icon != null
                          ? Icon(icon, size: 8, color: Colors.white)
                          : null,
                    ),
                    if (connectorHeight > 0)
                      SizedBox(
                        height: connectorHeight,
                        child: Container(
                          width: 2,
                          color: isPending
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF047857),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrent ? statusBgStatus : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color: isCompleted
                        ? const Color(0xFF047857)
                        : isCurrent
                            ? statusColorStatus
                            : const Color(0xFF9CA3AF),
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
