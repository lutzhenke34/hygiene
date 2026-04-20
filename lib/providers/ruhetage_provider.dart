// lib/providers/ruhetage_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../features/dashboard/models/ruhetage.dart';

final ruhetageNotifierProvider = StateNotifierProvider.family<RuhetageNotifier, AsyncValue<List<int>>, String>(
  (ref, betriebId) => RuhetageNotifier(ref, betriebId),
);

class RuhetageNotifier extends StateNotifier<AsyncValue<List<int>>> {
  final Ref ref;
  final String betriebId;
  final _supabase = Supabase.instance.client;

  RuhetageNotifier(this.ref, this.betriebId) : super(const AsyncValue.loading()) {
    _loadRuhetage();
  }

  Future<void> _loadRuhetage() async {
    try {
      final data = await _supabase
          .from('ruhetage')
          .select('ruhetage')
          .eq('betrieb_id', betriebId)
          .maybeSingle();

      if (data == null || data['ruhetage'] == null) {
        state = const AsyncValue.data([]);   // Leere Liste = keine Ruhetage (durchgehend geöffnet)
      } else {
        final list = List<int>.from(data['ruhetage']);
        state = AsyncValue.data(list);
      }
    } catch (e, stack) {
      debugPrint('Fehler beim Laden der Ruhetage: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> saveRuhetage(List<int> neueRuhetage) async {
    final finalList = neueRuhetage..sort();

    state = const AsyncValue.loading();

    try {
      await _supabase.from('ruhetage').upsert({
        'betrieb_id': betriebId,
        'ruhetage': finalList,
      }, onConflict: 'betrieb_id');

      state = AsyncValue.data(finalList);
      debugPrint('✅ Ruhetage gespeichert: $finalList');
    } catch (e, stack) {
      debugPrint('❌ Fehler beim Speichern der Ruhetage: $e');
      state = AsyncValue.error(e, stack);
      await _loadRuhetage();
    }
  }
}