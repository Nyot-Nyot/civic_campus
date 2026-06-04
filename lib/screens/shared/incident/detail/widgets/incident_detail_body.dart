import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/constants/app_constants.dart';
import 'package:civic_campus/data/providers/report_provider.dart';
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
  List<String>? _photoUrls;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPhotos);
  }

  Future<void> _loadPhotos() async {
    try {
      final urls = await context.read<ReportProvider>().getIncidentPhotoUrls(
        _incident.id,
      );
      if (mounted) setState(() => _photoUrls = urls);
    } catch (_) {
      if (mounted) setState(() => _photoUrls = []);
    }
  }

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

  String _getUnsplashUrl(String category) {
    switch (category) {
      case 'Toilet':
        return 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&q=80&w=600';
      case 'WiFi':
        return 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&q=80&w=600';
      case 'AC':
        return 'https://images.unsplash.com/photo-1585338107529-13afc5f02586?auto=format&fit=crop&q=80&w=600';
      case 'Lampu':
      case 'Listrik':
        return 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&q=80&w=600';
      case 'Kebersihan':
        return 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80&w=600';
      default:
        return 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&q=80&w=600';
    }
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

    final hasRealPhoto = _photoUrls != null && _photoUrls!.isNotEmpty;
    final heroUrl = hasRealPhoto
        ? _photoUrls!.first
        : _getUnsplashUrl(_incident.category);
    final gridUrls = hasRealPhoto ? _photoUrls!.sublist(1) : <String>[];

    return Stack(
      children: [
        // Large background photo (real or Unsplash fallback)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Image.network(
            heroUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: categoryColor.withValues(alpha: 0.12),
              child: Center(
                child: Icon(
                  categoryIcon,
                  size: 80,
                  color: categoryColor.withValues(alpha: 0.4),
                ),
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: categoryColor.withValues(alpha: 0.12),
                child: Center(
                  child: CircularProgressIndicator(
                    color: categoryColor,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),

        // Sliding Panel Content
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 250), // Overlaps the photo by 50px
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row (Category Icon + Title + Status)
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
                            child: Icon(categoryIcon, color: categoryColor, size: 24),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    IncidentTimeline.statusLabelsIndonesian[_incident.status] ?? _incident.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Info Section (Location, Category, Time, Priority)
                      _buildInfoRow(Icons.location_on, 'Lokasi', _incident.location),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.category_outlined, 'Kategori', _incident.category),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.access_time, 'Waktu', '${formatTimeAgo(_incident.timeAgo)} dilaporkan'),
                      const SizedBox(height: 12),
                      _buildPriorityRow(_incident.priority),

                      if (widget.showAdminActions) ...[
                        const SizedBox(height: 24),
                        _buildConfirmationSection(),
                        const SizedBox(height: 24),
                        _buildLinkedReportsSection(),
                      ] else ...[
                        if (_incident.confirmationCount > 0) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.people, 'Konfirmasi',
                              '+${_incident.confirmationCount} orang'),
                        ],
                      ],
                      const SizedBox(height: 32),

                      // Description Section
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 32),

                      // Timeline Section
                      const Text(
                        'Status Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 32),

                      // Photo Grid (Evidence) Section
                      const Text(
                        'Foto Bukti Lainnya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),
                      IncidentPhotoGrid(photoUrls: gridUrls),
                      const SizedBox(height: 32),

                      // Action buttons
                      _buildActions(context, widget.showStaffActions || widget.showAdminActions),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating Back Button
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF111827), size: 20),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
            ),
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
