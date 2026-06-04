class DuplicateSuggestion {
  final String title;
  final String location;
  final String category;
  final String building;
  final String floor;
  final String status;
  final int confirmCount;

  factory DuplicateSuggestion.fromJson(Map<String, dynamic> json) {
    return DuplicateSuggestion(
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      category: json['category'] as String? ?? '',
      building: json['building'] as String? ?? '',
      floor: json['floor'] as String? ?? '',
      status: json['status'] as String? ?? '',
      confirmCount: json['confirm_count'] as int? ?? 0,
    );
  }

  const DuplicateSuggestion({
    required this.title,
    required this.location,
    required this.category,
    required this.building,
    required this.floor,
    required this.status,
    required this.confirmCount,
  });
}
