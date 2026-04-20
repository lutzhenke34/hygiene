import '../core/supabase_client.dart';
import 'package:hygiene_app/models/user_model.dart';

class AuthService {
  Future<UserModel?> login(String phone, String pin) async {
    try {
      // Telefonnummer normalisieren (Leerzeichen, Bindestriche und Plus entfernen)
      final cleanPhone = phone.replaceAll(RegExp(r'[\s\-+]'), '');

      final response = await supabase
          .from('users')
          .select()
          .eq('phone', cleanPhone)
          .eq('pin', pin)
          .maybeSingle();

      print('Supabase Login Response: $response');

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
}   // ← Diese Klammer muss ganz am Ende stehen