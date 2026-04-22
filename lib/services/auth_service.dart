import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<UserModel?> login(String phone, String pin) async {
    try {
      print('Versuche Login mit Telefon: $phone | PIN: $pin');

      // Mitarbeiter-Login
      var response = await supabase
          .from('mitarbeiter')
          .select()
          .or('kontakt.eq.$phone,telefon.eq.$phone')
          .eq('pin', pin)
          .maybeSingle();

      if (response != null) {
        final user = UserModel.fromJson(response);

        await _updateLastLogin('mitarbeiter', response['id']);
        await _setMitarbeiterOnline(
          mitarbeiterId: response['id'],
          betriebId: response['betrieb_id'],
        );

        print('Mitarbeiter-Login erfolgreich: ${user.name ?? ''}');
        return user;
      }

      // Admin-Login
      response = await supabase
          .from('users')
          .select()
          .eq('phone', phone)
          .eq('pin', pin)
          .maybeSingle();

      if (response != null) {
        final user = UserModel.fromJson({
          ...response,
          'role': 'admin',
        });

        await _updateLastLogin('users', response['id']);

        print('Admin-Login erfolgreich');
        return user;
      }

      print('Kein Benutzer gefunden');
      return null;
    } catch (e) {
      print('Login-Fehler: $e');
      return null;
    }
  }

  Future<void> logout(UserModel? user) async {
    try {
      if (user != null && (user.role?.toLowerCase() != 'admin')) {
        await supabase
            .from('anwesenheit')
            .update({
              'aktiv': false,
              'logout_time': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('mitarbeiter_id', user.id)
            .eq('aktiv', true);
      }

      print('Logout erfolgreich');
    } catch (e) {
      print('Logout-Fehler: $e');
    }
  }

  Future<void> _updateLastLogin(String table, String id) async {
    try {
      await supabase.from(table).update({
        'last_login': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      print('Fehler beim Aktualisieren von last_login: $e');
    }
  }

  Future<void> _setMitarbeiterOnline({
    required String mitarbeiterId,
    required String? betriebId,
  }) async {
    if (betriebId == null || betriebId.isEmpty) return;

    try {
      // Alte offene Sessions dieses Mitarbeiters schließen
      await supabase
          .from('anwesenheit')
          .update({
            'aktiv': false,
            'logout_time': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('mitarbeiter_id', mitarbeiterId)
          .eq('aktiv', true);

      // Neue aktive Session anlegen
      await supabase.from('anwesenheit').insert({
        'mitarbeiter_id': mitarbeiterId,
        'betrieb_id': betriebId,
        'login_time': DateTime.now().toUtc().toIso8601String(),
        'aktiv': true,
      });
    } catch (e) {
      print('Fehler beim Setzen von anwesenheit: $e');
    }
  }
}
