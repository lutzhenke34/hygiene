class UserModel {
  final String id;
  final String phone;
  final String role;

  UserModel({
    required this.id,
    required this.phone,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
    );
  }

  // Optional – für spätere Updates nützlich
  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'role': role,
      };
}