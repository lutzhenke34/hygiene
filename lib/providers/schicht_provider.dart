import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/dashboard/models/schicht.dart';

part 'schicht_provider.g.dart';

final supabase = Supabase.instance.client;

@riverpod
class SchichtNotifier extends _$SchichtNotifier {
  @override
  Future<List<Schicht>> build(String betriebId) async {
    final data = await supabase
        .from('schichten')
        .select()
        .eq('betrieb_id', betriebId)
        .eq('aktiv', true)
        .order('start_zeit');

    return data.map((e) => Schicht.fromJson(e)).toList();
  }

  Future<void> addOrUpdate(Schicht schicht) async {
    try {
      if (schicht.id.isEmpty) {
        await supabase.from('schichten').insert(schicht.toJson());
      } else {
        await supabase
            .from('schichten')
            .update(schicht.toJson())
            .eq('id', schicht.id);
      }
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler bei Schicht addOrUpdate: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await supabase.from('schichten').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler beim Löschen der Schicht: $e');
      rethrow;
    }
  }

  // Hilfsmethode: Aktuelle Schicht basierend auf Uhrzeit ermitteln
  Future<Schicht?> getAktuelleSchicht(String betriebId) async {
    final jetzt = DateTime.now();
    final schichten = await future; // wartet auf build()

    for (var schicht in schichten) {
      final start = DateTime(jetzt.year, jetzt.month, jetzt.day, 
          schicht.startZeit.hour, schicht.startZeit.minute);
      final ende = DateTime(jetzt.year, jetzt.month, jetzt.day, 
          schicht.endeZeit.hour, schicht.endeZeit.minute);

      if (jetzt.isAfter(start) && jetzt.isBefore(ende)) {
        return schicht;
      }
    }
    return null; // keine passende Schicht
  }
}