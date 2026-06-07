import 'package:intl/intl.dart';

const statusOpen = 'Open';
const statusAssigned = 'Assigned';
const statusPendingBudget = 'Menunggu Anggaran';
const statusInProgress = 'In Progress';
const statusResolved = 'Resolved';
const statusClosed = 'Closed';

String formatTimeAgo(String raw) {
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
  return DateFormat('d MMM yyyy, HH:mm').format(dt);
}

class Incident {
  final String id;
  final String title;
  final String location;
  final String category;
  final String status;
  final String timeAgo;
  final int photoCount;
  final int confirmationCount;
  final String description;
  final String? assignedTo;
  final String priority;
  final DateTime createdAt;

  const Incident({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.status,
    required this.timeAgo,
    this.photoCount = 1,
    this.confirmationCount = 0,
    this.description = '',
    this.assignedTo,
    this.priority = 'Rendah',
    required this.createdAt,
  });

  bool isOverdue([DateTime? now]) {
    const terminal = {statusResolved, statusClosed};
    if (terminal.contains(status)) return false;
    return (now ?? DateTime.now()).difference(createdAt) > const Duration(hours: 24);
  }
  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location_name'] as String? ?? json['location_id'] as String,
      category: json['category_name'] as String? ?? '',
      status: json['status'] as String,
      timeAgo: formatTimeAgo(json['updated_at'] as String),
      photoCount: json['photo_count'] as int? ?? 0,
      confirmationCount: json['confirm_count'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      assignedTo: json['assigned_to_name'] as String? ?? json['assigned_to'] as String?,
      priority: json['priority_label'] as String? ?? 'Rendah',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Incident copyWith({
    String? id,
    String? title,
    String? location,
    String? category,
    String? status,
    String? timeAgo,
    int? photoCount,
    int? confirmationCount,
    String? description,
    String? assignedTo,
    String? priority,
    DateTime? createdAt,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      category: category ?? this.category,
      status: status ?? this.status,
      timeAgo: timeAgo ?? this.timeAgo,
      photoCount: photoCount ?? this.photoCount,
      confirmationCount: confirmationCount ?? this.confirmationCount,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
