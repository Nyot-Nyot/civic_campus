import 'package:flutter/material.dart';

import 'package:civic_campus/data/dummy_data.dart';
import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/repositories/incident_repository.dart';

class AssignStaffSheet extends StatefulWidget {
  final Incident incident;
  final ValueChanged<Incident> onAssigned;

  const AssignStaffSheet({super.key, required this.incident, required this.onAssigned});

  @override
  State<AssignStaffSheet> createState() => _AssignStaffSheetState();
}

class _AssignStaffSheetState extends State<AssignStaffSheet> {
  late String _selectedPriority;
  final _repo = IncidentRepository();
  bool _isAssigning = false;

  static const _priorities = ['Tinggi', 'Sedang', 'Rendah'];

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.incident.priority;
  }

  @override
  Widget build(BuildContext context) {
    final isAssigned = widget.incident.status == statusAssigned;

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
            Text(
              isAssigned ? 'Tugaskan Ulang Staff' : 'Assign Staff',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih staff yang akan menangani insiden ini.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isAssigning ? null : _assign,
                icon: _isAssigning
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add, size: 20),
                label: const Text('Budi Teknisi'),
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
            const SizedBox(height: 20),
            const Text(
              'Prioritas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(_priorities.length, (index) {
                final p = _priorities[index];
                final sel = _selectedPriority == p;
                return Padding(
                  padding: EdgeInsets.only(right: index < _priorities.length - 1 ? 8 : 0),
                  child: ChoiceChip(
                    label: Text(p),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedPriority = p),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: sel ? Colors.white : const Color(0xFF6B7280),
                    ),
                    backgroundColor: const Color(0xFFF3F4F6),
                    selectedColor: const Color(0xFF111827),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur due date akan tersedia setelah integrasi kalender.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: const Color(0xFF374151),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 16),
                    SizedBox(width: 8),
                    Text('Tambah Due Date (opsional)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assign() async {
    setState(() => _isAssigning = true);
    final notes = _selectedPriority != widget.incident.priority
        ? 'Ditugaskan ke Budi Teknisi, prioritas: $_selectedPriority'
        : 'Ditugaskan ke Budi Teknisi';
    final ok = await _repo.updateStatus(
      widget.incident.id,
      statusAssigned,
      notes: notes,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan tidak ditemukan.')),
      );
      return;
    }
    final updated = widget.incident.copyWith(
      status: statusAssigned,
      assignedTo: 'Budi Teknisi',
      priority: _selectedPriority,
    );
    final idx = allIncidents.indexWhere((i) => i.id == widget.incident.id);
    if (idx != -1) {
      allIncidents[idx] = updated;
    }
    widget.onAssigned(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insiden ditugaskan ke Budi Teknisi.')),
    );
  }
}
