// lib/models/user.dart
enum Role {
  reader('reader'),
  clerk('clerk'),
  manager('manager');

  final String value;
  const Role(this.value);

  factory Role.fromString(String role) {
    return Role.values.firstWhere(
      (e) => e.value == role,
      orElse: () => Role.reader,
    );
  }
}

class User {
  final String id;
  final String email;
  final String? name;
  final DateTime? createdAt;
  final Role role;
  final String? password; // Added for login purposes (see warning in SupabaseService)

  User({
    required this.id,
    required this.email,
    this.name,
    this.createdAt,
    this.role = Role.reader,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      role: Role.fromString(json['role']),
      password: json['password'], // Assuming password field exists for demonstration
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'role': role.value,
      'password': password, // For signup, will be sent
    };
  }
}