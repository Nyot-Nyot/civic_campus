import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/constants/app_constants.dart';
import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/widgets/photo_picker_sheet.dart';

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

  bool get _canSubmit =>
      _activeStatus != null && !(_isResolving && _noteController.text.trim().isEmpty);

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
        child: SingleChildScrollView(
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
                'Pilih status baru untuk laporan ini:',
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
                      onPressed: isActive
                          ? null
                          : () => setState(() => _activeStatus = status),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(
                          color: isActive ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        foregroundColor: const Color(0xFF111827),
                        backgroundColor:
                            isActive ? const Color(0xFFF3F4F6) : null,
                      ),
                      child: Row(
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
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check, size: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_photos[index]),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.broken_image_outlined,
                                size: 28, color: Color(0xFF9CA3AF)),
                          ),
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
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _canSubmit && _activeStatus != null
                      ? () => _updateStatus(_activeStatus!)
                      : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(_isSubmitting ? 'Mengirim...' : 'Kirim'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSubmitting = false;

  void _showPhotoPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => PhotoPickerSheet(
        onCamera: () => _onPhotoPicked(ImageSource.camera, ctx),
        onGallery: () => _onPhotoPicked(ImageSource.gallery, ctx),
      ),
    );
  }

  Future<void> _onPhotoPicked(ImageSource source, BuildContext sheetCtx) async {
    Navigator.of(sheetCtx).pop();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _photos.add(picked.path));
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isSubmitting = true);
    final provider = context.read<IncidentProvider>();
    final err = await provider.updateStatus(widget.incident.id, status);
    if (!mounted) return;
    if (err != null) {
      setState(() => _isSubmitting = false);
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
    widget.onUpdated(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status "${widget.incident.title}" diubah ke "$status".')),
    );
  }
}
