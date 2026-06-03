import 'package:flutter/material.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/repositories/incident_repository.dart';
import 'package:civic_campus/data/constants/app_constants.dart';
import 'package:civic_campus/data/dummy_data.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/assign_staff_sheet.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/incident_detail_body.dart';

class IncidentDetailScreen extends StatefulWidget {
  final Incident incident;
  final bool showStaffActions;
  final bool showAdminActions;

  const IncidentDetailScreen({
    super.key,
    required this.incident,
    this.showStaffActions = false,
    this.showAdminActions = false,
  });

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  final _repo = IncidentRepository();
  late Incident _incident;
  final _bodyKey = GlobalKey<IncidentDetailBodyState>();

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
  }

  Future<void> _handleStickyAction() async {
    if (widget.showAdminActions) {
      if (_incident.status == statusOpen || _incident.status == statusAssigned) {
        _showAssignSheet();
        return;
      }
      if (_incident.status == statusResolved) {
        final ok = await _repo.updateStatus(_incident.id, statusClosed);
        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan tidak ditemukan.')),
          );
          return;
        }
        setState(() {
          _incident = allIncidents.firstWhere(
            (i) => i.id == _incident.id,
            orElse: () => _incident,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_incident.id} ditutup.')),
        );
        return;
      }
      return;
    }
    if (_incident.status == statusInProgress) {
      _bodyKey.currentState?.showResolveSheet(context);
      return;
    }
    final ok = await _repo.updateStatus(_incident.id, statusInProgress);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan tidak ditemukan.')),
      );
      return;
    }
    setState(() {
      _incident = allIncidents.firstWhere(
        (i) => i.id == _incident.id,
        orElse: () => _incident,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_incident.id} mulai dikerjakan.',
        ),
      ),
    );
  }

  void _showAssignSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => AssignStaffSheet(
        incident: _incident,
        onAssigned: (updated) {
          setState(() => _incident = updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showSticky;
    String stickyLabel;
    IconData stickyIcon;
    Color stickyColor;

    if (widget.showAdminActions) {
      showSticky = _incident.status == statusOpen ||
          _incident.status == statusAssigned ||
          _incident.status == statusResolved;
      if (_incident.status == statusOpen) {
        stickyLabel = 'Assign';
        stickyIcon = Icons.person_add_alt_1;
        stickyColor = const Color(0xFF3B82F6);
      } else if (_incident.status == statusAssigned) {
        stickyLabel = 'Tugaskan Ulang';
        stickyIcon = Icons.swap_horiz;
        stickyColor = const Color(0xFF3B82F6);
      } else if (_incident.status == statusResolved) {
        stickyLabel = 'Tutup Insiden';
        stickyIcon = Icons.check_circle_outline;
        stickyColor = const Color(0xFF10B981);
      } else {
        stickyLabel = '';
        stickyIcon = Icons.error_outline;
        stickyColor = const Color(0xFF6B7280);
      }
    } else {
      showSticky = widget.showStaffActions &&
          (_incident.status == statusAssigned || _incident.status == statusInProgress);
      stickyLabel = _incident.status == statusAssigned
          ? 'Mulai Kerjakan'
          : 'Selesaikan Tugas';
      stickyIcon = _incident.status == statusAssigned
          ? Icons.play_arrow_rounded
          : Icons.check_circle_outline;
      stickyColor = _incident.status == statusInProgress
          ? priorityColors[_incident.priority] ?? const Color(0xFF3B82F6)
          : const Color(0xFF3B82F6);
    }

    return Scaffold(
      body: SafeArea(
        child: IncidentDetailBody(
          key: _bodyKey,
          incident: _incident,
          showStaffActions: widget.showStaffActions,
          showAdminActions: widget.showAdminActions,
          onStatusUpdated: (updated) {
            setState(() => _incident = updated);
          },
        ),
      ),
      bottomNavigationBar: showSticky
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: widget.showStaffActions && _incident.status == statusInProgress
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _bodyKey.currentState?.showNotesSheet(context),
                              icon: const Icon(Icons.edit_note, size: 20),
                              label: const Text('Tambah Catatan'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                foregroundColor: const Color(0xFF374151),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _handleStickyAction,
                              icon: Icon(stickyIcon, size: 20),
                              label: Text(stickyLabel),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                backgroundColor: stickyColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _handleStickyAction,
                          icon: Icon(stickyIcon, size: 20),
                          label: Text(stickyLabel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: stickyColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
              ),
            )
          : null,
    );
  }
}
