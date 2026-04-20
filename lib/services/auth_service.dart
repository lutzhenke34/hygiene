import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<UserModel?> login(String phone, String pin) async {
    try {
      print('🔍 Versuche Login mit Telefon: $phone | PIN: $pin');

      // === 1. Mitarbeiter Login (Tabelle: mitarbeiter mit kontakt) ===
      print('→ Suche in mitarbeiter-Tabelle (Spalte: kontakt)...');
      var response = await supabase
          .from('mitarbeiter')
          .select()
          .or('kontakt.eq.$phone,telefon.eq.$phone')
          .eq('pin', pin)
          .maybeSingle();

      if (response != null) {
        final user = UserModel.fromJson(response);

        await _updateLastLogin('mitarbeiter', response['id']);

        print('✅ Mitarbeiter-Login erfolgreich: ${user.name ?? ''} (${user.role ?? 'Mitarbeiter'})');
        return user;
      }

      // === 2. Admin Login (Tabelle: users mit phone) ===
      print('→ Suche in users-Tabelle als Admin (Spalte: phone)...');
      response = await supabase
          .from('users')
          .select()
          .eq('phone', phone)           // Hier ist es "phone"
          .eq('pin', pin)
          .maybeSingle();

      if (response != null) {
        final user = UserModel.fromJson({
          ...response,
          'role': 'admin',
        });

        await _updateLastLogin('users', response['id']);

        print('✅ Admin-Login erfolgreich: ${user.name ?? response['email'] ?? 'Admin'}');
        return user;
      }

      print('❌ Kein Benutzer gefunden für Telefon=$phone und PIN=$pin');
      return null;

    } catch (e) {
      print('❌ Login-Fehler: $e');
      return null;
    }
  }

  // Hilfsmethode zum Aktualisieren von last_login
  Future<void> _updateLastLogin(String table, String id) async {
    try {
      await supabase
          .from(table)
          .update({
            'last_login': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);

      print('✅ last_login für $table erfolgreich aktualisiert');
    } catch (e) {
      print('⚠️ Fehler beim Aktualisieren von last_login in Tabelle $table: $e');
    }
  }

  Future<void> logout() async {
    print('✅ Logout aufgerufen');
  }
}