import 'betrieb.dart';

abstract class BetriebRepository {
  Future<List<Betrieb>> getAll();
  Future<Betrieb> create({
    required String name,
    required String kategorie,
    required String betriebsart,
    required String risikoprofil,
    required bool schichtbetrieb,
  });
  Future<void> delete(String id);
}