// lib/models/user_model.dart
class UserModel {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? betriebId;        // wichtig für Multi-Tenant
  final bool isAdmin;

  UserModel({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.betriebId,
    this.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      betriebId: json['betrieb_id'],
      isAdmin: json['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'betrieb_id': betriebId,
        'is_admin': isAdmin,
      };
}