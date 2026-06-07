import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/providers/auth_provider.dart';
import 'package:civic_campus/data/providers/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RabFormSheet extends StatefulWidget {
  final Incident incident;

  const RabFormSheet({super.key, required this.incident});

  static void show(BuildContext context, Incident incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => RabFormSheet(incident: incident),
    );
  }

  @override
  State<RabFormSheet> createState() => _RabFormSheetState();
}

class _RabFormSheetState extends State<RabFormSheet> {
  final _items = <Map<String, dynamic>>[];
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  static const _units = ['meter', 'buah', 'paket', 'liter', 'unit', 'set'];

  @override
  void initState() {
    super.initState();
    _addItem();
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final item in _items) {
      (item['descCtrl'] as TextEditingController).dispose();
      (item['qtyCtrl'] as TextEditingController).dispose();
      (item['costCtrl'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add({
        'descCtrl': TextEditingController(),
        'qtyCtrl': TextEditingController(text: '1'),
        'unitCtrl': TextEditingController(text: _units[0]),
        'costCtrl': TextEditingController(),
      });
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    setState(() {
      final item = _items.removeAt(index);
      (item['descCtrl'] as TextEditingController).dispose();
      (item['qtyCtrl'] as TextEditingController).dispose();
      (item['unitCtrl'] as TextEditingController).dispose();
      (item['costCtrl'] as TextEditingController).dispose();
    });
  }

  double get _totalCost {
    double total = 0;
    for (final item in _items) {
      final qty =
          double.tryParse((item['qtyCtrl'] as TextEditingController).text) ?? 0;
      final cost =
          double.tryParse((item['costCtrl'] as TextEditingController).text) ??
          0;
      total += qty * cost;
    }
    return total;
  }

  Future<void> _submit() async {
    for (int i = 0; i < _items.length; i++) {
      final desc = (_items[i]['descCtrl'] as TextEditingController).text.trim();
      if (desc.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${i + 1}: deskripsi wajib diisi')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final itemsJson = _items
        .map(
          (item) => {
            'description': (item['descCtrl'] as TextEditingController).text
                .trim(),
            'qty':
                int.tryParse((item['qtyCtrl'] as TextEditingController).text) ??
                1,
            'unit': (item['unitCtrl'] as TextEditingController).text.trim(),
            'unit_cost':
                double.tryParse(
                  (item['costCtrl'] as TextEditingController).text,
                ) ??
                0,
          },
        )
        .toList();

    final budgetProvider = context.read<BudgetProvider>();
    final authProvider = context.read<AuthProvider>();

    final error = await budgetProvider.create(
      incidentId: widget.incident.id,
      userId: authProvider.userId ?? '',
      items: itemsJson,
      totalCost: _totalCost,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $error')));
      setState(() => _isSubmitting = false);
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Buat RAB',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.incident.title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final descCtrl =
                          item['descCtrl'] as TextEditingController;
                      final qtyCtrl = item['qtyCtrl'] as TextEditingController;
                      final unitCtrl =
                          item['unitCtrl'] as TextEditingController;
                      final costCtrl =
                          item['costCtrl'] as TextEditingController;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Item ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_items.length > 1)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Color(0xFFEF4444),
                                        size: 20,
                                      ),
                                      onPressed: () => _removeItem(index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: descCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Deskripsi',
                                  hintText: 'Mis: Kabel listrik 2.5mm',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: qtyCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Jumlah',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: unitCtrl.text,
                                      items: _units
                                          .map(
                                            (u) => DropdownMenuItem(
                                              value: u,
                                              child: Text(u),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() => unitCtrl.text = v);
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Satuan',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: costCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Harga Satuan (Rp)',
                                  hintText: '25000',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    OutlinedButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Item'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                        hintText: 'Mis: butuh pembelian di toko elektrik',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Total Estimasi:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            'Rp ${_formatRupiah(_totalCost)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Kirim RAB'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatRupiah(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
  }
}
