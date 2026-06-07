import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/core/pdf_service.dart';
import 'package:civic_campus/data/providers/budget_provider.dart';

class AdminBudgetApprovalTab extends StatefulWidget {
  const AdminBudgetApprovalTab({super.key});

  @override
  State<AdminBudgetApprovalTab> createState() => _AdminBudgetApprovalTabState();
}

class _AdminBudgetApprovalTabState extends State<AdminBudgetApprovalTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<BudgetProvider>().loadPending();
  }

  void _showDetail(Map<String, dynamic> request) {
    final items = request['items'] as List? ?? [];
    final total = (request['total_cost'] as num?)?.toDouble() ?? 0;
    final notes = request['notes'] as String?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => _BudgetDetailSheet(
        request: request,
        items: items,
        total: total,
        notes: notes,
        onAction: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final pending = provider.pendingRequests;

        if (pending.isEmpty) {
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              children: [
                const SizedBox(height: 120),
                const Icon(Icons.check_circle_outline,
                    size: 64, color: Color(0xFFD1D5DB)),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Tidak ada RAB yang perlu disetujui.',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Persetujuan Anggaran',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${pending.length} RAB menunggu persetujuan',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...pending.map((req) => _buildCard(req)),
            ],
          ),
        );
      },
    );
  }

  String _incidentLabel(Map<String, dynamic> req) {
    final incident = req['incident'] as Map<String, dynamic>?;
    if (incident == null) return 'Insiden tidak ditemukan';
    final title = incident['title'] as String? ?? 'Tanpa judul';
    final building = incident['building'] as String? ??
        incident['building_name'] as String? ??
        '';
    if (building.isNotEmpty) return '$title ($building)';
    return title;
  }

  Widget _buildCard(Map<String, dynamic> req) {
    final total = (req['total_cost'] as num?)?.toDouble() ?? 0;
    final createdAt = req['created_at'] as String? ?? '';
    final version = (req['version'] as num?)?.toInt() ?? 1;
    final label = _incidentLabel(req);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(req),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.request_quote,
                    color: Color(0xFFB45309), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RAB #v$version',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${_formatRupiah(total)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRupiah(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _BudgetDetailSheet extends StatefulWidget {
  final Map<String, dynamic> request;
  final List items;
  final double total;
  final String? notes;
  final VoidCallback onAction;

  const _BudgetDetailSheet({
    required this.request,
    required this.items,
    required this.total,
    this.notes,
    required this.onAction,
  });

  @override
  State<_BudgetDetailSheet> createState() => _BudgetDetailSheetState();
}

class _BudgetDetailSheetState extends State<_BudgetDetailSheet> {
  final _reasonController = TextEditingController();
  bool _isProcessing = false;
  bool _hasApproved = false;
  bool _isPrinting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    final id = widget.request['id'] as String;
    final provider = context.read<BudgetProvider>();
    setState(() => _isProcessing = true);
    final err = await provider.approve(id, _reasonController.text.trim());
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      setState(() => _isProcessing = false);
      return;
    }
    setState(() {
      _hasApproved = true;
      _isProcessing = false;
    });
  }

  Future<void> _reject() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan penolakan wajib diisi.')),
      );
      return;
    }
    final id = widget.request['id'] as String;
    final provider = context.read<BudgetProvider>();
    setState(() => _isProcessing = true);
    final err = await provider.reject(id, reason);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      setState(() => _isProcessing = false);
      return;
    }
    widget.onAction();
    Navigator.of(context).pop();
  }

  Map<String, dynamic> get _incidentFromRequest {
    final incident = widget.request['incident'] as Map<String, dynamic>?;
    return incident ?? {};
  }

  String _generateDocNumber() {
    final now = DateTime.now();
    final month = _romanMonth(now.month);
    final year = now.year;
    final count = (widget.request['version'] as num?)?.toInt() ?? 1;
    return 'RAB/$year/$month/${count.toString().padLeft(3, '0')}';
  }

  String _romanMonth(int m) {
    const months = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'];
    return months[m - 1];
  }

  Future<void> _printPdf() async {
    setState(() => _isPrinting = true);

    try {
      final incident = _incidentFromRequest;
      final docNumber = _generateDocNumber();
      final incidentTitle = incident['title'] as String? ?? 'Insiden';
      final location = _buildLocation(incident);
      final category = incident['category_name'] as String? ??
          incident['category'] as String? ?? '';
      final technicianName = incident['assigned_to_name'] as String? ?? '';

      final items = (widget.request['items'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      final totalCost = (widget.request['total_cost'] as num?)?.toDouble() ?? 0;

      await RabPdfService.share(
        docNumber: docNumber,
        incidentTitle: incidentTitle,
        location: location,
        category: category,
        technicianName: technicianName,
        items: items,
        totalCost: totalCost,
        staffName: '',
        version: (widget.request['version'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal generate PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  String _buildLocation(Map<String, dynamic> incident) {
    final parts = <String>[
      if (incident['building_name'] != null) incident['building_name'] as String,
      if (incident['building'] != null) incident['building'] as String,
      if (incident['floor_name'] != null) incident['floor_name'] as String,
      if (incident['area_name'] != null) incident['area_name'] as String,
    ];
    return parts.isEmpty ? '-' : parts.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: _hasApproved ? 0.5 : 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48, height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _hasApproved ? 'RAB Disetujui' : 'Detail RAB',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        widget.onAction();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: _hasApproved ? _buildApprovedState() : _buildDetailState(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildApprovedState() {
    return [
      const SizedBox(height: 24),
      const Icon(Icons.check_circle, size: 64, color: Color(0xFF047857)),
      const SizedBox(height: 16),
      const Center(
        child: Text(
          'RAB berhasil disetujui!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 8),
      const Center(
        child: Text(
          'Cetak PDF untuk pengajuan ke\nbagian keuangan kampus.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),
      ),
      const SizedBox(height: 32),
      ElevatedButton.icon(
        onPressed: _isPrinting ? null : _printPdf,
        icon: _isPrinting
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.picture_as_pdf, size: 20),
        label: const Text('Cetak PDF'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: const Color(0xFFB45309),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: () {
          widget.onAction();
          Navigator.of(context).pop();
        },
        child: const Text('Selesai'),
      ),
    ];
  }

  List<Widget> _buildDetailState() {
    return [
      const Text(
        'Item Anggaran',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      const SizedBox(height: 12),
      ...widget.items.asMap().entries.map((entry) {
        final i = entry.key + 1;
        final item = entry.value as Map<String, dynamic>;
        final desc = item['description'] as String? ?? '';
        final qty = (item['qty'] as num?)?.toInt() ?? 0;
        final unit = item['unit'] as String? ?? '';
        final cost = (item['unit_cost'] as num?)?.toDouble() ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$i.',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(desc, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '$qty $unit x Rp ${cost.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rp ${(qty * cost).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Spacer(),
            Text(
              'Rp ${widget.total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ],
        ),
      ),
      if (widget.notes != null && widget.notes!.isNotEmpty) ...[
        const SizedBox(height: 16),
        const Text(
          'Catatan Teknisi',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Text(
          widget.notes!,
          style: const TextStyle(color: Color(0xFF374151)),
        ),
      ],
      const SizedBox(height: 24),
      TextField(
        controller: _reasonController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Catatan Admin',
          hintText: 'Alasan setujui/tolak (wajib jika menolak)',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16, vertical: 14,
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _reject,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Tolak'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _approve,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 18),
              label: const Text('Setujui'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFF047857),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 32),
    ];
  }
}
