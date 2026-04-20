import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/dashboard/models/kuehlgeraet.dart';

part 'kuehlgeraet_provider.g.dart';

final supabase = Supabase.instance.client;

@riverpod
class KuehlgeraetNotifier extends _$KuehlgeraetNotifier {
  @override
  Future<List<Kuehlgeraet>> build(String betriebId) async {
    final data = await supabase
        .from('kuehlgeraete')
        .select()
        .eq('betrieb_id', betriebId)
        .order('name');

    return data.map((e) => Kuehlgeraet.fromJson(e)).toList();
  }

  Future<void> addOrUpdate(Kuehlgeraet g) async {
    try {
      if (g.id.isEmpty) {
        await supabase.from('kuehlgeraete').insert(g.toJson());
      } else {
        await supabase
            .from('kuehlgeraete')
            .update(g.toJson())
            .eq('id', g.id);
      }
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler bei Kühlgerät addOrUpdate: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await supabase.from('kuehlgeraete').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler beim Löschen des Kühlgeräts: $e');
      rethrow;
    }
  }
}