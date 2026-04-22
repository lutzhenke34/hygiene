import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final onlineMitarbeiterProvider =
    StreamProvider.family<int, String>((ref, String betriebId) {
  final client = Supabase.instance.client;

  return client
      .from('anwesenheit')
      .stream(primaryKey: ['id'])
      .eq('betrieb_id', betriebId)
      .eq('aktiv', true)
      .map((rows) {
        final ids = <String>{};

        for (final row in rows) {
          final mitarbeiterId = row['mitarbeiter_id'];
          if (mitarbeiterId is String && mitarbeiterId.isNotEmpty) {
            ids.add(mitarbeiterId);
          }
        }

        return ids.length;
      });
});
