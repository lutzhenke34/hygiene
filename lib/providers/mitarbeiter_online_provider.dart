import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final onlineMitarbeiterIdsProvider =
    StreamProvider.family<Set<String>, String>((ref, String betriebId) {
  final client = Supabase.instance.client;

  return client
      .from('anwesenheit')
      .stream(primaryKey: ['id'])
      .eq('betrieb_id', betriebId)
      .map((rows) {
        final ids = <String>{};

        for (final row in rows) {
          final aktiv = row['aktiv'] == true;
          final mitarbeiterId = row['mitarbeiter_id'];

          if (aktiv && mitarbeiterId is String && mitarbeiterId.isNotEmpty) {
            ids.add(mitarbeiterId);
          }
        }

        return ids;
      });
});

final onlineMitarbeiterProvider =
    Provider.family<AsyncValue<int>, String>((ref, String betriebId) {
  final idsAsync = ref.watch(onlineMitarbeiterIdsProvider(betriebId));
  return idsAsync.whenData((ids) => ids.length);
});
