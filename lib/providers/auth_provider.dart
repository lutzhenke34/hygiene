import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hygiene_app/models/user_model.dart';

import '../services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null);

  final _service = AuthService();

  // WICHTIG: Named parameters, damit der Aufruf mit : funktioniert
  Future<UserModel?> login({required String phone, required String pin}) async {
    final user = await _service.login(phone, pin);
    state = user;
    return user;
  }

  Future<void> logout() async {
    state = null;
    print('✅ Logout erfolgreich');
  }
}