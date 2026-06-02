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
