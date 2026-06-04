class User {
  final String name;
  final String role;
  final String email;
  final bool isActive;

  const User({
    required this.name,
    required this.role,
    required this.email,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String? ?? 'User',
      role: json['role'] as String? ?? 'Student',
      email: json['email'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  User copyWith({
    String? name,
    String? role,
    String? email,
    bool? isActive,
  }) {
    return User(
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }
}
