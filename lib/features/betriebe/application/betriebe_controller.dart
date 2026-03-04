import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/betrieb.dart';
import '../domain/betrieb_repository.dart';
import '../data/betrieb_repository_impl.dart';

final betriebeControllerProvider =
    AsyncNotifierProvider<BetriebeController, List<Betrieb>>(
        BetriebeController.new);

class BetriebeController extends AsyncNotifier<List<Betrieb>> {
  late final BetriebRepository _repository;

  @override
  Future<List<Betrieb>> build() async {
    _repository = ref.read(betriebRepositoryProvider);
    return _repository.getAll();
  }

  Future<void> addBetrieb({
    required String name,
    required String kategorie,
    required String betriebsart,
    required String risikoprofil,
    required bool schichtbetrieb,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final newBetrieb = await _repository.create(
        name: name,
        kategorie: kategorie,
        betriebsart: betriebsart,
        risikoprofil: risikoprofil,
        schichtbetrieb: schichtbetrieb,
      );

      return [...?state.value, newBetrieb];
    });
  }

  Future<void> remove(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      return state.value!.where((b) => b.id != id).toList();
    });
  }
}