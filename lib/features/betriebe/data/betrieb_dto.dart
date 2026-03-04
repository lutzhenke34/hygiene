import '../domain/betrieb.dart';

class BetriebDto {
  final String id;
  final String name;
  final String kategorie;
  final String betriebsart;
  final String risikoprofil;
  final bool schichtbetrieb;

  BetriebDto({
    required this.id,
    required this.name,
    required this.kategorie,
    required this.betriebsart,
    required this.risikoprofil,
    required this.schichtbetrieb,
  });

  factory BetriebDto.fromJson(Map<String, dynamic> json) {
    return BetriebDto(
      id: json['id'],
      name: json['name'],
      kategorie: json['kategorie'],
      betriebsart: json['betriebsart'],
      risikoprofil: json['risikoprofil'],
      schichtbetrieb: json['schichtbetrieb'] ?? false,
    );
  }

  Betrieb toDomain() => Betrieb(
        id: id,
        name: name,
        kategorie: kategorie,
        betriebsart: betriebsart,
        risikoprofil: risikoprofil,
        schichtbetrieb: schichtbetrieb,
      );
}