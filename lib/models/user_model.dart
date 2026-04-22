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
    final vorname = json['vorname']?.toString().trim();
    final nachname = json['nachname']?.toString().trim();
    final fullName = [vorname, nachname]
        .where((value) => value != null && value.isNotEmpty)
        .join(' ');

    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? (fullName.isNotEmpty ? fullName : null),
      email: json['email'],
      phone: json['phone'] ?? json['kontakt'] ?? json['telefon'],
      role: json['role'] ?? json['rolle'],
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
