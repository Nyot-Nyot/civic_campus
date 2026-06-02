class User {
  final String name;
  final String role;
  final String email;

  const User({
    required this.name,
    required this.role,
    required this.email,
  });

  User copyWith({
    String? name,
    String? role,
    String? email,
  }) {
    return User(
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
    );
  }
}
