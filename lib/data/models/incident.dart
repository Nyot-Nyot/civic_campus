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
  });
}
