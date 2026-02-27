// lib/models/auth_model.dart
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String token;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
