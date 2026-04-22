import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/dashboard/models/aufgabe.dart';
import 'schicht_provider.dart';

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
        .order('faellig_bis', ascending: true);

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
      print('Fehler bei Aufgabe addOrUpdate: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await supabase.from('aufgaben').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print('Fehler beim Loeschen der Aufgabe: $e');
      rethrow;
    }
  }

  Future<void> toggleErledigt(String id) async {
    try {
      final current = await supabase
          .from('aufgaben')
          .select('erledigt')
          .eq('id', id)
          .maybeSingle();

      if (current == null) return;

      final erledigt = current['erledigt'] == true;

      await supabase
          .from('aufgaben')
          .update({'erledigt': !erledigt})
          .eq('id', id);

      ref.invalidateSelf();
    } catch (e) {
      print('Fehler beim Umschalten von erledigt: $e');
      rethrow;
    }
  }
}

typedef EmployeeAufgabenParams = ({String betriebId, String rolle});

final employeeAufgabenProvider =
    FutureProvider.family<List<Aufgabe>, EmployeeAufgabenParams>(
  (ref, params) async {
    final schichtNotifier =
        ref.read(schichtNotifierProvider(params.betriebId).notifier);
    final aktuelleSchicht =
        await schichtNotifier.getAktuelleSchicht(params.betriebId);

    final alleAufgaben =
        await ref.watch(aufgabeNotifierProvider(params.betriebId).future);

    return alleAufgaben.where((a) {
      final rollePasst = a.rolle == null ||
          a.rolle == 'Alle' ||
          a.rolle!.toLowerCase() == params.rolle.toLowerCase();

      final schichtPasst =
          a.schichtId == null || a.schichtId == aktuelleSchicht?.id;

      return rollePasst && schichtPasst && !a.erledigt;
    }).toList();
  },
);
