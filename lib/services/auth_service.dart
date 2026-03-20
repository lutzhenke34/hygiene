import '../core/supabase_client.dart';
import '../models/user_model.dart';

class AuthService {
  Future<UserModel?> login(String phone, String pin) async {
    try {
      // Telefonnummer normalisieren (Leerzeichen, Bindestriche entfernen)
      final cleanPhone = phone.replaceAll(RegExp(r'[\s\-+]'), '');

      final response = await supabase
          .from('users')                      // ← neu: users statt profiles
          .select()
          .eq('phone', cleanPhone)
          .eq('pin', pin)
          .maybeSingle();

      print('Supabase Login Response: $response'); // ← Debugging

      if (response == null) {
        print('Kein Benutzer gefunden für $cleanPhone / $pin');
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e, stackTrace) {
      print('Login Fehler: $e');
      print('Stacktrace: $stackTrace');
      return null;
    }
  }
}