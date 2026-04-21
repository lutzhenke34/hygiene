// lib/providers/mitarbeiter_online_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final onlineMitarbeiterProvider =
    StreamProvider.family<int, String>((ref, String betriebId) {
  final client = Supabase.instance.client;

  return client
      .from('mitarbeiter')
      .stream(primaryKey: ['id'])
      .eq('betrieb_id', betriebId)
      .map((rows) {
        final now = DateTime.now();
        int activeCount = 0;

        for (final row in rows) {
          final lastLoginRaw = row['last_login'];

          if (lastLoginRaw == null) continue;

          DateTime? lastLogin;

          if (lastLoginRaw is String) {
            lastLogin = DateTime.tryParse(lastLoginRaw);
          } else if (lastLoginRaw is DateTime) {
            lastLogin = lastLoginRaw;
          }

          if (lastLogin == null) continue;

          final diff = now.difference(lastLogin);

          if (diff < const Duration(minutes: 8)) {
            activeCount++;
          }
        }

        return activeCount;
      });
});