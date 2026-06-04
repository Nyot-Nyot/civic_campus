import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/data/providers/user_provider.dart';

class AssignStaffSheet extends StatefulWidget {
  final Incident incident;
  final ValueChanged<Incident> onAssigned;

  const AssignStaffSheet({super.key, required this.incident, required this.onAssigned});

  @override
  State<AssignStaffSheet> createState() => _AssignStaffSheetState();
}

class _AssignStaffSheetState extends State<AssignStaffSheet> {
  String? _selectedStaffId;
  String? _selectedStaffName;
  late String _selectedPriority;
  bool _isAssigning = false;
  bool _isLoadingStaff = true;

  static const _priorities = ['Tinggi', 'Sedang', 'Rendah'];

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.incident.priority;
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final provider = context.read<UserProvider>();
    await provider.load(role: 'Maintenance Staff', activeOnly: true);
    if (!mounted) return;
    setState(() => _isLoadingStaff = false);
  }

  @override
  Widget build(BuildContext context) {
    final staff = context.watch<UserProvider>().getStaff();
    final isAssigned = widget.incident.status == statusAssigned;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isAssigned ? 'Tugaskan Ulang Staff' : 'Assign Staff',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih staff yang akan menangani insiden ini.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            if (_isLoadingStaff)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (staff.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Tidak ada staff tersedia.', style: TextStyle(color: Color(0xFF6B7280)))),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: staff.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = staff[index];
                    final id = s['id'] as String;
                    final name = s['name'] as String;
                    final isSel = _selectedStaffId == id;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() {
                          _selectedStaffId = id;
                          _selectedStaffName = name;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: isSel ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person, size: 18,
                                    color: isSel ? Colors.white : const Color(0xFF6B7280)),
                              ),
                              const SizedBox(width: 12),
                              Text(name,
                                style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500,
                                  color: isSel ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_selectedStaffName != null) ...[
              const SizedBox(height: 20),
              const Text('Prioritas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
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
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: sel ? Colors.white : const Color(0xFF6B7280),
                      ),
                      backgroundColor: const Color(0xFFF3F4F6),
                      selectedColor: const Color(0xFF111827),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  onPressed: _isAssigning ? null : _assign,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color(0xFF111827),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _isAssigning
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Assign', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _assign() async {
    if (_selectedStaffId == null || _selectedStaffName == null) return;
    setState(() => _isAssigning = true);
    final provider = context.read<IncidentProvider>();
    final err = await provider.updateStatus(
      widget.incident.id,
      statusAssigned,
      assignedTo: _selectedStaffId,
      priorityLabel: _selectedPriority,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() => _isAssigning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $err')),
      );
      return;
    }
    await provider.loadById(widget.incident.id);
    if (!mounted) return;
    final updated = provider.selectedIncident != null
        ? Incident.fromJson(provider.selectedIncident!)
        : widget.incident;
    widget.onAssigned(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Insiden ditugaskan ke $_selectedStaffName.')),
    );
  }
}
