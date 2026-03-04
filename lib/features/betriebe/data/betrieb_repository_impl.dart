import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/supabase_provider.dart';
import '../domain/betrieb.dart';
import '../domain/betrieb_repository.dart';
import 'betrieb_dto.dart';

final betriebRepositoryProvider = Provider<BetriebRepository>((ref) {
  final client = ref.read(supabaseProvider);
  return BetriebRepositoryImpl(client);
});

class BetriebRepositoryImpl implements BetriebRepository {
  final dynamic client;

  BetriebRepositoryImpl(this.client);

  @override
  Future<List<Betrieb>> getAll() async {
    try {
      final response =
          await client.from('betriebe').select().order('name');

      return response
          .map<Betrieb>((e) => BetriebDto.fromJson(e).toDomain())
          .toList();
    } catch (e) {
      throw AppException("Fehler beim Laden der Betriebe", e);
    }
  }

  @override
  Future<Betrieb> create({
    required String name,
    required String kategorie,
    required String betriebsart,
    required String risikoprofil,
    required bool schichtbetrieb,
  }) async {
    try {
      final response = await client.from('betriebe').insert({
        "name": name,
        "kategorie": kategorie,
        "betriebsart": betriebsart,
        "risikoprofil": risikoprofil,
        "schichtbetrieb": schichtbetrieb,
      }).select().single();

      return BetriebDto.fromJson(response).toDomain();
    } catch (e) {
      throw AppException("Fehler beim Erstellen", e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await client.from('betriebe').delete().eq('id', id);
    } catch (e) {
      throw AppException("Fehler beim Löschen", e);
    }
  }
}