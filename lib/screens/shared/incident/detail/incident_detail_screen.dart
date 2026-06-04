import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
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
  late Incident _incident;
  final _bodyKey = GlobalKey<IncidentDetailBodyState>();

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
  }

  Future<void> _handleStickyAction() async {
    final provider = context.read<IncidentProvider>();

    if (widget.showAdminActions) {
      if (_incident.status == statusOpen || _incident.status == statusAssigned) {
        _showAssignSheet();
        return;
      }
      if (_incident.status == statusResolved) {
        final err = await provider.updateStatus(_incident.id, statusClosed);
        if (!mounted) return;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err)),
          );
          return;
        }
        await provider.loadById(_incident.id);
        if (!mounted) return;
        setState(() {
          if (provider.selectedIncident != null) {
            _incident = Incident.fromJson(provider.selectedIncident!);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_incident.title} ditutup.')),
        );
        return;
      }
      return;
    }
    if (_incident.status == statusInProgress) {
      _bodyKey.currentState?.showResolveSheet(context);
      return;
    }
    final err = await provider.updateStatus(_incident.id, statusInProgress);
    if (!mounted) return;
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    await provider.loadById(_incident.id);
    if (!mounted) return;
    setState(() {
      if (provider.selectedIncident != null) {
        _incident = Incident.fromJson(provider.selectedIncident!);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_incident.title} mulai dikerjakan.',
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
    Color stickyColor = const Color(0xFF111827);

    if (widget.showAdminActions) {
      showSticky = _incident.status == statusOpen ||
          _incident.status == statusAssigned ||
          _incident.status == statusResolved;
      if (_incident.status == statusOpen) {
        stickyLabel = 'Assign';
        stickyIcon = Icons.person_add_alt_1;
      } else if (_incident.status == statusAssigned) {
        stickyLabel = 'Tugaskan Ulang';
        stickyIcon = Icons.swap_horiz;
      } else if (_incident.status == statusResolved) {
        stickyLabel = 'Tutup Insiden';
        stickyIcon = Icons.check_circle_outline;
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
    }

    return Scaffold(
      body: IncidentDetailBody(
        key: _bodyKey,
        incident: _incident,
        showStaffActions: widget.showStaffActions,
        showAdminActions: widget.showAdminActions,
        onStatusUpdated: (updated) {
          setState(() => _incident = updated);
        },
      ),
      bottomNavigationBar: showSticky
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
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
                                    borderRadius: BorderRadius.circular(30),
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
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
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
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
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
