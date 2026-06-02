import 'package:flutter/material.dart';

import '../data/constants/app_constants.dart';
import '../data/dummy_data.dart';
import '../data/models/incident.dart';
import '../data/repositories/incident_repository.dart';
import 'photo_picker_sheet.dart';

class StatusUpdateSheet extends StatefulWidget {
  final Incident incident;
  final List<String> nextStatuses;
  final ValueChanged<Incident> onUpdated;

  const StatusUpdateSheet({
    super.key,
    required this.incident,
    required this.nextStatuses,
    required this.onUpdated,
  });

  @override
  State<StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends State<StatusUpdateSheet> {
  final _noteController = TextEditingController();
  final _repo = IncidentRepository();
  final _photos = <String>[];
  String? _activeStatus;

  late final bool _isResolving;

  @override
  void initState() {
    super.initState();
    _isResolving = widget.nextStatuses.contains(statusResolved);
  }

  @override
  void dispose() {
    _noteController.dispose();
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Update Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ubah status laporan ${widget.incident.id} ke status berikutnya:',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            ...widget.nextStatuses.map((status) {
              final isActive = _activeStatus == status;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isActive ? null : () => _updateStatus(status),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: BorderSide(
                        color: isActive ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      foregroundColor: const Color(0xFF111827),
                    ),
                    child: isActive
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF111827),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: statusColors[status] ?? const Color(0xFF6B7280),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(status),
                            ],
                          ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              _isResolving ? 'Catatan pekerjaan (wajib diisi)' : 'Catatan pekerjaan (opsional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            if (_photos.isEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPhotoPicker(context),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Tambah Foto'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    foregroundColor: const Color(0xFF374151),
                  ),
                ),
              )
            else
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    if (index == _photos.length) {
                      return GestureDetector(
                        onTap: () => _showPhotoPicker(context),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Icon(Icons.add, color: Color(0xFF9CA3AF)),
                        ),
                      );
                    }
                    return Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined, size: 28, color: Color(0xFF9CA3AF)),
                          SizedBox(height: 2),
                          Text('Foto', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: _isResolving
                    ? 'Jelaskan hasil perbaikan... (wajib)'
                    : 'Tambahkan catatan...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => PhotoPickerSheet(
        onCamera: () => _onPhotoPicked(context),
        onGallery: () => _onPhotoPicked(context),
      ),
    );
  }

  void _onPhotoPicked(BuildContext context) {
    setState(() => _photos.add('mock_photo_${_photos.length + 1}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur akan tersedia setelah integrasi kamera/galeri.')),
    );
  }

  Future<void> _updateStatus(String status) async {
    final note = _noteController.text;
    if (_isResolving && note.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan pekerjaan wajib diisi sebelum menyelesaikan tugas.')),
      );
      return;
    }
    setState(() => _activeStatus = status);
    final ok = await _repo.updateStatus(
      widget.incident.id,
      status,
      notes: note,
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
    widget.onUpdated(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status ${widget.incident.id} diubah ke "$status".')),
    );
  }
}
