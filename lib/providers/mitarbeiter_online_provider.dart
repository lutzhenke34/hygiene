// lib/providers/mitarbeiter_online_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Zählt, wie viele Mitarbeiter aktuell eingeloggt sind (letzter Login < 8 Minuten)
final onlineMitarbeiterProvider = StreamProvider.family<int, String>((ref, betriebId) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('mitarbeiter')
      .stream(primaryKey: ['id'])
      .eq('betrieb_id', betriebId)
      .map((rows) {
        final now = DateTime.now();
        int activeCount = 0;

        for (final row in rows) {
          final lastLoginStr = row['last_login'] as String?;

          if (lastLoginStr != null) {
            try {
              final lastLogin = DateTime.parse(lastLoginStr);
              // Mitarbeiter gilt als eingeloggt, wenn der letzte Login weniger als 8 Minuten her ist
              if (now.difference(lastLogin) < const Duration(minutes: 8)) {
                activeCount++;
              }
            } catch (e) {
              // Ungültiges Datum überspringen
              continue;
            }
          }
        }

        debugPrint('Online Mitarbeiter für Betrieb $betriebId: $activeCount');
        return activeCount;
      });
});