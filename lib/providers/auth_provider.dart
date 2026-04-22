// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hygiene_app/models/user_model.dart';

import '../services/auth_service.dart';
import '../services/presence_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null);

  final _service = AuthService();
  final _presence = PresenceService();

  // LOGIN
  Future<UserModel?> login({
    required String phone,
    required String pin,
  }) async {
    final user = await _service.login(phone, pin);

    if (user != null) {
      state = user;

      // 🟢 Presence starten (ONLINE)
     _presence.start(
  userId: user.id,
  betriebId: user.betriebId,
  role: user.role,
);

    }

    return user;
  }

  // LOGOUT
 Future<void> logout() async {
  _presence.stop();

  await _service.logout(state);

  state = null;

  print('Logout erfolgreich');
}
}