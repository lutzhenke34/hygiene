import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null);

  final _service = AuthService();

  Future<UserModel?> login(String phone, String pin) async {
    final user = await _service.login(phone, pin);
    state = user;
    return user;
  }
}