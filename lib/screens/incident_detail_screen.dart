import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/dummy_data.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;
  final bool showStaffActions;

  const IncidentDetailScreen({
    super.key,
    required this.incident,
    this.showStaffActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final prioColor =
        priorityColors[incident.priority] ?? const Color(0xFF6B7280);

    final showSticky = showStaffActions &&
        (incident.status == 'Assigned' || incident.status == 'In Progress');
    final stickyLabel = incident.status == 'Assigned'
        ? 'Mulai Kerjakan'
        : 'Selesaikan Tugas';
    final stickyIcon = incident.status == 'Assigned'
        ? Icons.play_arrow_rounded
        : Icons.check_circle_outline;

    return Scaffold(
      body: SafeArea(
        child: _IncidentDetailBody(
          incident: incident,
          showStaffActions: showStaffActions,
        ),
      ),
      bottomNavigationBar: showSticky
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${incident.id} ${stickyLabel == 'Mulai Kerjakan' ? 'mulai dikerjakan' : 'ditandai selesai'}.',
                          ),
                        ),
                      );
                    },
                    icon: Icon(stickyIcon, size: 20),
                    label: Text(stickyLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: prioColor,
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

class _IncidentDetailBody extends StatelessWidget {
  final Incident incident;
  final bool showStaffActions;

  const _IncidentDetailBody({
    required this.incident,
    this.showStaffActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryIcon =
        categoryIcons[incident.category] ?? Icons.help_outline;
    final categoryColor =
        categoryColors[incident.category] ?? const Color(0xFF9CA3AF);
    final statusColor =
        statusColors[incident.status] ?? const Color(0xFF6B7280);
    final statusBg =
        statusBgColors[incident.status] ?? const Color(0xFFF3F4F6);

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
                          incident.title,
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
                                incident.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              incident.id,
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
              _buildInfoRow(Icons.location_on, 'Lokasi', incident.location),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.category_outlined, 'Kategori', incident.category),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.access_time, 'Waktu', '${incident.timeAgo} dilaporkan'),
              if (incident.confirmationCount > 0) ...[
                const SizedBox(height: 12),
                _buildInfoRow(Icons.people, 'Konfirmasi',
                    '+${incident.confirmationCount} orang'),
              ],
              const SizedBox(height: 12),
              _buildPriorityRow(incident.priority),
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
                incident.description.isNotEmpty
                    ? incident.description
                    : 'Tidak ada deskripsi tambahan.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: incident.description.isNotEmpty
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
              _buildTimeline(),
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
              _buildPhotoGrid(),
              const SizedBox(height: 28),
              _buildActions(context, showStaffActions),
              const SizedBox(height: 16),
            ]),
          ),
        ),
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

  Widget _buildTimeline() {
    final currentIndex =
        statusFlow.indexOf(incident.status).clamp(0, statusFlow.length - 1);

    return Column(
      children: List.generate(statusFlow.length, (index) {
        final status = statusFlow[index];
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;
        final isPending = index > currentIndex;

        Color circleColor;
        IconData? icon;
        if (isCompleted) {
          circleColor = const Color(0xFF047857);
          icon = Icons.check;
        } else if (isCurrent) {
          circleColor = const Color(0xFF1D4ED8);
          icon = Icons.circle;
        } else {
          circleColor = const Color(0xFFE5E7EB);
          icon = null;
        }

        final statusColorStatus =
            statusColors[status] ?? const Color(0xFF6B7280);
        final statusBgStatus =
            statusBgColors[status] ?? const Color(0xFFF3F4F6);

        final connectorHeight = index < statusFlow.length - 1 ? 20.0 : 0.0;

        return SizedBox(
          height: 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: icon != null
                          ? Icon(icon, size: 8, color: Colors.white)
                          : null,
                    ),
                    if (connectorHeight > 0)
                      SizedBox(
                        height: connectorHeight,
                        child: Container(
                          width: 2,
                          color: isPending
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF047857),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrent ? statusBgStatus : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color: isCompleted
                        ? const Color(0xFF047857)
                        : isCurrent
                            ? statusColorStatus
                            : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPhotoGrid() {
    if (incident.photoCount == 0) {
      return const Text(
        'Tidak ada foto bukti.',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: incident.photoCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined,
                  size: 28, color: Color(0xFFD1D5DB)),
              SizedBox(height: 4),
              Text(
                'Foto',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context, bool isStaff) {
    final isResolvedOrClosed =
        incident.status == 'Resolved' || incident.status == 'Closed';

    final currentIdx = statusFlow.indexOf(incident.status);
    final nextStatuses = <String>[];
    if (currentIdx < statusFlow.length - 1 && isStaff) {
      for (var i = currentIdx + 1; i < statusFlow.length; i++) {
        nextStatuses.add(statusFlow[i]);
      }
    }

    return Column(
      children: [
        if (isStaff && nextStatuses.isNotEmpty) ...[
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
        if (isResolvedOrClosed) ...[
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

  void _showReopenSheet(BuildContext context) {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
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
                  'Minta Dibuka Kembali',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jelaskan alasan mengapa laporan ${incident.id} perlu ditinjau ulang.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: 'Tulis alasan di sini...',
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
                      borderSide: const BorderSide(
                          color: Color(0xFF111827), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (reasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text('Alasan harus diisi.'),
                          ),
                        );
                        return;
                      }
                      Navigator.of(sheetContext).pop();
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: const Text('Permintaan Dikirim'),
                          content: const Text(
                            'Permintaan pembukaan kembali laporan telah dikirim ke admin. Silakan tunggu review.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: const Color(0xFF111827),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text('Kirim Permintaan'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() => reasonController.dispose());
  }

  void _showStatusUpdateSheet(BuildContext context, List<String> nextStatuses) {
    final noteController = TextEditingController();
    final isResolving = nextStatuses.contains('Resolved');

    final photos = <String>[];
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
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
                      'Ubah status laporan ${incident.id} ke status berikutnya:',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...nextStatuses.map((status) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Status ${incident.id} diubah ke "$status".',
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            foregroundColor: const Color(0xFF111827),
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
                            ],
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 8),
                    Text(
                      isResolving ? 'Bukti foto perbaikan (opsional)' : 'Catatan pekerjaan (opsional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (photos.isEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                              ),
                              builder: (ctx) => SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
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
                                        'Tambah Bukti Foto',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildPhotoSourceTile(ctx, Icons.camera_alt_outlined, 'Ambil Foto',
                                          'Gunakan kamera untuk mengambil foto'),
                                      const SizedBox(height: 12),
                                      _buildPhotoSourceTile(ctx, Icons.photo_library_outlined, 'Pilih dari Galeri',
                                          'Pilih foto yang sudah ada'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                          label: Text(isResolving ? 'Tambah Foto Bukti' : 'Tambah Foto'),
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
                          itemCount: photos.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, index) {
                            if (index == photos.length) {
                              return GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                                    ),
                                    builder: (ctx) => SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
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
                                              'Tambah Bukti Foto',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111827),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            _buildPhotoSourceTile(ctx, Icons.camera_alt_outlined, 'Ambil Foto',
                                                'Gunakan kamera untuk mengambil foto'),
                                            const SizedBox(height: 12),
                                            _buildPhotoSourceTile(ctx, Icons.photo_library_outlined, 'Pilih dari Galeri',
                                                'Pilih foto yang sudah ada'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                      controller: noteController,
                      maxLines: 3,
                      maxLength: 300,
                      decoration: InputDecoration(
                        hintText: isResolving
                            ? 'Jelaskan hasil perbaikan...'
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
                          borderSide: const BorderSide(
                              color: Color(0xFF111827), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => noteController.dispose());
  }

  Widget _buildPhotoSourceTile(BuildContext context, IconData icon, String title, String subtitle) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur akan tersedia setelah integrasi kamera/galeri.')),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
