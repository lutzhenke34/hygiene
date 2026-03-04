import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ── Betriebe ────────────────────────────────────────────────────────────────
final betriebeProvider =
    AsyncNotifierProvider<BetriebeNotifier, List<Map<String, dynamic>>>(
        BetriebeNotifier.new);

class BetriebeNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() => _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await ref.read(supabaseProvider)
        .from('betriebe')
        .select()
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> addBetrieb(Map<String, dynamic> data) async {
    state = const AsyncLoading();

    try {
      final response = await ref.read(supabaseProvider)
          .from('betriebe')
          .insert(data)
          .select()
          .single();

      final newItem = Map<String, dynamic>.from(response);
      final previous = state.value ?? [];
      state = AsyncData([...previous, newItem]);
      return newItem;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final selectedBetriebIdProvider = StateProvider<String?>((ref) => null);

final selectedBetriebProvider = Provider<Map<String, dynamic>?>((ref) {
  final betriebe = ref.watch(betriebeProvider);
  final id = ref.watch(selectedBetriebIdProvider);

  return betriebe.maybeWhen(
    data: (list) {
      if (id == null) return null;
      try {
        return list.firstWhere((b) => b['id'] == id);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});

// ── Abhängige Listen (family Provider) ──────────────────────────────────────
final kuehlgeraeteProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>(
  (ref, betriebId) async {
    if (betriebId == null || betriebId.isEmpty) return [];
    try {
      final data = await ref.watch(supabaseProvider)
          .from('kuehlgeraete')
          .select()
          .eq('betrieb_id', betriebId)
          .order('name');
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  },
);

final geraeteProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>(
  (ref, betriebId) async {
    if (betriebId == null || betriebId.isEmpty) return [];
    final data = await ref.watch(supabaseProvider)
        .from('geraete')
        .select()
        .eq('betrieb_id', betriebId)
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  },
);

final mitarbeiterProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>(
  (ref, betriebId) async {
    if (betriebId == null || betriebId.isEmpty) return [];
    final data = await ref.watch(supabaseProvider)
        .from('mitarbeiter')
        .select()
        .eq('betrieb_id', betriebId)
        .order('nachname');
    return List<Map<String, dynamic>>.from(data);
  },
);