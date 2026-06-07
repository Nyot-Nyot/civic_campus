import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/assign_staff_sheet.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/incident_detail_body.dart';
import 'package:civic_campus/screens/shared/incident/detail/widgets/rab_form_sheet.dart';

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

  Future<void> _handleAdminAction() async {
    final provider = context.read<IncidentProvider>();

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
  }

  Future<void> _handleStaffStartWork() async {
    final provider = context.read<IncidentProvider>();
    final err = await provider.updateStatus(_incident.id, statusInProgress);
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
      SnackBar(content: Text('${_incident.title} mulai dikerjakan.')),
    );
  }

  void _handleStaffBuatRAB() {
    RabFormSheet.show(context, _incident);
  }

  void _handleStaffLihatRAB() {
    RabFormSheet.show(context, _incident);
  }

  void _handleStaffResolve() {
    _bodyKey.currentState?.showResolveSheet(context);
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
    final showSticky = widget.showAdminActions
        ? (_incident.status == statusOpen ||
            _incident.status == statusAssigned ||
            _incident.status == statusResolved)
        : widget.showStaffActions &&
            (_incident.status == statusAssigned ||
                _incident.status == statusPendingBudget ||
                _incident.status == statusInProgress);

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
                  child: _buildStickyButtons(),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStickyButtons() {
    if (widget.showAdminActions) {
      return _buildSingleButton(
        label: _incident.status == statusOpen
            ? 'Assign'
            : _incident.status == statusAssigned
                ? 'Tugaskan Ulang'
                : 'Tutup Insiden',
        icon: _incident.status == statusOpen
            ? Icons.person_add_alt_1
            : _incident.status == statusAssigned
                ? Icons.swap_horiz
                : Icons.check_circle_outline,
        onPressed: _handleAdminAction,
      );
    }

    if (_incident.status == statusAssigned) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handleStaffStartWork,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Mulai Kerjakan'),
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
              onPressed: _handleStaffBuatRAB,
              icon: const Icon(Icons.request_quote_outlined, size: 20),
              label: const Text('Buat RAB'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFFB45309),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    }

    if (_incident.status == statusPendingBudget) {
      return _buildSingleButton(
        label: 'Lihat RAB',
        icon: Icons.description_outlined,
        onPressed: _handleStaffLihatRAB,
      );
    }

    // InProgress — show notes + resolve
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _bodyKey.currentState?.showNotesSheet(context),
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
            onPressed: _handleStaffResolve,
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text('Selesaikan Tugas'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111827),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
