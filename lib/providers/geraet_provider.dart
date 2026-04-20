import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/dashboard/models/geraet.dart';

part 'geraet_provider.g.dart';

final supabase = Supabase.instance.client;

@riverpod
class GeraetNotifier extends _$GeraetNotifier {
  @override
  Future<List<Geraet>> build(String betriebId) async {
    final data = await supabase
        .from('geraete')
        .select()
        .eq('betrieb_id', betriebId)
        .order('name');

    return data.map((e) => Geraet.fromJson(e)).toList();
  }

  Future<void> addOrUpdate(Geraet g) async {
    try {
      if (g.id.isEmpty) {
        await supabase.from('geraete').insert(g.toJson());
      } else {
        await supabase
            .from('geraete')
            .update(g.toJson())
            .eq('id', g.id);
      }
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler bei Gerät addOrUpdate: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await supabase.from('geraete').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler beim Löschen des Geräts: $e');
      rethrow;
    }
  }
}