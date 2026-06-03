import 'package:flutter/material.dart';

import 'package:civic_campus/data/dummy_data.dart';
import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/repositories/incident_repository.dart';

class RejectSheet extends StatefulWidget {
  final Incident incident;
  final ValueChanged<Incident> onRejected;

  const RejectSheet({super.key, required this.incident, required this.onRejected});

  @override
  State<RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<RejectSheet> {
  final _reasonController = TextEditingController();
  final _repo = IncidentRepository();
  bool _isSubmitting = false;

  late final bool _fromResolved;

  @override
  void initState() {
    super.initState();
    _fromResolved = widget.incident.status == statusResolved;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tolak Insiden',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _fromResolved
                  ? 'Hasil kerja staff ditolak. Insiden akan kembali ke status Assigned untuk ditinjau ulang.'
                  : 'Jelaskan alasan penolakan insiden ini.',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Alasan penolakan...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Tolak Insiden'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan harus diisi.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final newStatus = _fromResolved ? statusAssigned : widget.incident.status;
    final ok = await _repo.updateStatus(
      widget.incident.id,
      newStatus,
      notes: 'Ditolak: $reason',
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan tidak ditemukan.')),
      );
      return;
    }
    final updated = allIncidents.firstWhere(
      (i) => i.id == widget.incident.id,
      orElse: () => widget.incident,
    );
    widget.onRejected(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _fromResolved
              ? 'Insiden dikembalikan ke Assigned.'
              : 'Insiden ditolak.',
        ),
      ),
    );
  }
}
