import 'package:flutter/material.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/constants/app_constants.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/incident_photo_grid.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/incident_timeline.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/notes_sheet.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/reject_sheet.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/reopen_sheet.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/status_update_sheet.dart';

class IncidentDetailBody extends StatefulWidget {
  final Incident incident;
  final bool showStaffActions;
  final bool showAdminActions;
  final ValueChanged<Incident>? onStatusUpdated;

  const IncidentDetailBody({
    super.key,
    required this.incident,
    this.showStaffActions = false,
    this.showAdminActions = false,
    this.onStatusUpdated,
  });

  @override
  State<IncidentDetailBody> createState() => IncidentDetailBodyState();
}

class IncidentDetailBodyState extends State<IncidentDetailBody> {
  Incident get _incident => widget.incident;

  void showResolveSheet(BuildContext context) {
    _showStatusUpdateSheet(context, [statusResolved]);
  }

  void showNotesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return NotesSheet(
          incident: _incident,
          onSaved: (updated) {
            setState(() {});
            widget.onStatusUpdated?.call(updated);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryIcon =
        categoryIcons[_incident.category] ?? Icons.help_outline;
    final categoryColor =
        categoryColors[_incident.category] ?? const Color(0xFF9CA3AF);
    final statusColor =
        statusColors[_incident.status] ?? const Color(0xFF6B7280);
    final statusBg =
        statusBgColors[_incident.status] ?? const Color(0xFFF3F4F6);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    categoryColor.withValues(alpha: 0.3),
                    categoryColor.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Center(
                child: Icon(categoryIcon,
                    size: 72, color: categoryColor.withValues(alpha: 0.4)),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        Icon(categoryIcon, color: categoryColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _incident.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _incident.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _incident.id,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow(Icons.location_on, 'Lokasi', _incident.location),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.category_outlined, 'Kategori', _incident.category),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.access_time, 'Waktu', '${_incident.timeAgo} dilaporkan'),
              const SizedBox(height: 12),
              _buildPriorityRow(_incident.priority),
              if (widget.showAdminActions) ...[
                const SizedBox(height: 20),
                _buildConfirmationSection(),
                const SizedBox(height: 20),
                _buildLinkedReportsSection(),
              ] else ...[
                if (_incident.confirmationCount > 0) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.people, 'Konfirmasi',
                      '+${_incident.confirmationCount} orang'),
                ],
              ],
              const SizedBox(height: 28),
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _incident.description.isNotEmpty
                    ? _incident.description
                    : 'Tidak ada deskripsi tambahan.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: _incident.description.isNotEmpty
                      ? const Color(0xFF374151)
                      : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Status Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              IncidentTimeline(
                currentStatus: _incident.status,
                statusFlow: statusFlow,
                statusColors: statusColors,
                statusBgColors: statusBgColors,
              ),
              const SizedBox(height: 28),
              const Text(
                'Foto Bukti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 14),
              IncidentPhotoGrid(photoCount: _incident.photoCount),
              const SizedBox(height: 28),
              _buildActions(context, widget.showStaffActions || widget.showAdminActions),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people, color: Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_incident.confirmationCount} mahasiswa',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'mengonfirmasi insiden ini',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedReportsSection() {
    final dummyReports = [
      'Andi M. — ${_incident.timeAgo}',
      'Siti R. — ${_incident.timeAgo}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laporan Terkait',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(dummyReports.length, (index) {
          final r = dummyReports[index];
          final isLast = index == dummyReports.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    r,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityRow(String priority) {
    final color = priorityColors[priority] ?? const Color(0xFF6B7280);
    final bg = priorityBgColors[priority] ?? const Color(0xFFF3F4F6);
    return Row(
      children: [
        const Icon(Icons.flag_outlined, size: 16, color: Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          'Prioritas: ',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            priority,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isStaff) {
    final isResolvedOrClosed =
        _incident.status == statusResolved || _incident.status == statusClosed;
    final isAdmin = widget.showAdminActions;
    final isTerminal = _incident.status == statusClosed;

    final currentIdx = statusFlow.indexOf(_incident.status);
    final nextStatuses = <String>[];
    if (currentIdx < statusFlow.length - 1 && (isStaff || isAdmin)) {
      for (var i = currentIdx + 1; i < statusFlow.length; i++) {
        nextStatuses.add(statusFlow[i]);
      }
    }

    return Column(
      children: [
        if ((isStaff || isAdmin) && nextStatuses.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showStatusUpdateSheet(context, nextStatuses),
              icon: const Icon(Icons.update, size: 20),
              label: const Text('Update Status'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF111827),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (!isAdmin) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Laporan dikonfirmasi. Terima kasih!'),
                  ),
                );
              },
              icon: const Icon(Icons.how_to_reg, size: 20),
              label: const Text('Konfirmasi Laporan Ini'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF111827),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ],
        if (isAdmin && !isTerminal) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showRejectSheet(context),
              icon: const Icon(Icons.block, size: 20),
              label: const Text('Tolak'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                foregroundColor: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
        if (isResolvedOrClosed && !isAdmin) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showReopenSheet(context);
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Minta Dibuka Kembali'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                foregroundColor: const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showRejectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => RejectSheet(
        incident: _incident,
        onRejected: (updated) {
          widget.onStatusUpdated?.call(updated);
        },
      ),
    );
  }

  void _showReopenSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => ReopenSheet(
        incidentId: _incident.id,
      ),
    );
  }

  void _showStatusUpdateSheet(BuildContext context, List<String> nextStatuses) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => StatusUpdateSheet(
        incident: _incident,
        nextStatuses: nextStatuses,
        onUpdated: (updated) {
          widget.onStatusUpdated?.call(updated);
        },
      ),
    );
  }
}
