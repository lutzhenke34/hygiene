import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/dashboard/models/aufgabe.dart';

part 'aufgabe_provider.g.dart';

final supabase = Supabase.instance.client;

@riverpod
class AufgabeNotifier extends _$AufgabeNotifier {
  @override
  Future<List<Aufgabe>> build(String betriebId) async {
    final data = await supabase
        .from('aufgaben')
        .select()
        .eq('betrieb_id', betriebId)
        .order('faellig_bis')
        .order('erledigt');

    return data.map((e) => Aufgabe.fromJson(e)).toList();
  }

  Future<void> addOrUpdate(Aufgabe aufgabe) async {
    try {
      if (aufgabe.id.isEmpty) {
        await supabase.from('aufgaben').insert(aufgabe.toJson());
      } else {
        await supabase
            .from('aufgaben')
            .update(aufgabe.toJson())
            .eq('id', aufgabe.id);
      }
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler bei Aufgabe addOrUpdate: $e');
      rethrow;
    }
  }

  Future<void> toggleErledigt(String id) async {
    try {
      await supabase
          .from('aufgaben')
          .update({
            'erledigt': true,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler beim Erledigen: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await supabase.from('aufgaben').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler beim Löschen der Aufgabe: $e');
      rethrow;
    }
  }
}