import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final supabase = Supabase.instance.client;

  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<UserModel?> login(String phone, String pin) async {
  try {
    final response = await supabase
        .from('users')
        .select()
        .eq('phone', phone)
        .eq('pin', pin)
        .maybeSingle();

    print('RESPONSE: $response'); // 👈 wichtig

    if (response == null) {
      print('Kein Benutzer gefunden');
      return null;
    }

    return UserModel.fromMap(response);
  } catch (e) {
    print('FEHLER LOGIN: $e'); // 👈 wichtig
    return null;
  }
}