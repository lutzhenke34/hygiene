import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/dashboard/models/hygiene_aufgabe.dart';

part 'hygiene_aufgabe_provider.g.dart';

final supabase = Supabase.instance.client;

@riverpod
class HygieneAufgabeNotifier extends _$HygieneAufgabeNotifier {
  @override
  Future<List<HygieneAufgabe>> build(String betriebId) async {
    final data = await supabase
        .from('hygiene_aufgaben')
        .select()
        .eq('betrieb_id', betriebId)
        .order('faellig_bis')
        .order('erledigt');

    return data.map((e) => HygieneAufgabe.fromJson(e)).toList();
  }

  Future<void> addOrUpdate(HygieneAufgabe aufgabe) async {
    try {
      if (aufgabe.id.isEmpty) {
        await supabase.from('hygiene_aufgaben').insert(aufgabe.toJson());
      } else {
        await supabase
            .from('hygiene_aufgaben')
            .update(aufgabe.toJson())
            .eq('id', aufgabe.id);
      }
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler bei Hygieneaufgabe addOrUpdate: $e');
      rethrow;
    }
  }

  Future<void> toggleErledigt(String id) async {
    try {
      await supabase
          .from('hygiene_aufgaben')
          .update({'erledigt': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler beim Erledigen: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await supabase.from('hygiene_aufgaben').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler beim Löschen der Aufgabe: $e');
      rethrow;
    }
  }
}