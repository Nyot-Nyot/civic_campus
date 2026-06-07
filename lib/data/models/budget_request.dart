class BudgetItem {
  final String description;
  final int qty;
  final String unit;
  final double unitCost;

  const BudgetItem({
    required this.description,
    required this.qty,
    required this.unit,
    required this.unitCost,
  });

  double get total => qty * unitCost;

  Map<String, dynamic> toJson() => {
        'description': description,
        'qty': qty,
        'unit': unit,
        'unit_cost': unitCost,
      };

  factory BudgetItem.fromJson(Map<String, dynamic> json) => BudgetItem(
        description: json['description'] as String? ?? '',
        qty: (json['qty'] as num?)?.toInt() ?? 0,
        unit: json['unit'] as String? ?? '',
        unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0,
      );
}

class BudgetRequest {
  final String id;
  final String incidentId;
  final int version;
  final List<BudgetItem> items;
  final double totalCost;
  final String? notes;
  final String status;
  final String? adminNotes;
  final String createdBy;
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetRequest({
    required this.id,
    required this.incidentId,
    this.version = 1,
    this.items = const [],
    this.totalCost = 0,
    this.notes,
    this.status = 'Menunggu',
    this.adminNotes,
    required this.createdBy,
    this.reviewedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetRequest.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    List<BudgetItem> items = [];
    if (itemsRaw is List) {
      items = itemsRaw
          .map((e) => BudgetItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return BudgetRequest(
      id: json['id'] as String,
      incidentId: json['incident_id'] as String,
      version: (json['version'] as num?)?.toInt() ?? 1,
      items: items,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'Menunggu',
      adminNotes: json['admin_notes'] as String?,
      createdBy: json['created_by'] as String,
      reviewedBy: json['reviewed_by'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
