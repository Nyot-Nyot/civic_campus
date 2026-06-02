const statusOpen = 'Open';
const statusAssigned = 'Assigned';
const statusInProgress = 'In Progress';
const statusResolved = 'Resolved';
const statusClosed = 'Closed';

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
    this.priority = 'Sedang',
    required this.createdAt,
  });

  bool isOverdue([DateTime? now]) {
    const terminal = {statusResolved, statusClosed};
    if (terminal.contains(status)) return false;
    return (now ?? DateTime.now()).difference(createdAt) > const Duration(hours: 24);
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
