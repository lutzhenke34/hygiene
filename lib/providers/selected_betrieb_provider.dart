import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedBetriebIdProvider =
    StateNotifierProvider<SelectedBetriebIdNotifier, AsyncValue<String?>>(
        (ref) => SelectedBetriebIdNotifier());

class SelectedBetriebIdNotifier
    extends StateNotifier<AsyncValue<String?>> {
  SelectedBetriebIdNotifier() : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('selected_betrieb_id');
    state = AsyncData(id);
  }

  Future<void> set(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_betrieb_id', id);
    state = AsyncData(id);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_betrieb_id');
    state = const AsyncData(null);
  }
}