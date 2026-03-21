class Betrieb {
  final String id;
  final String name;
  final String kategorie;
  final String betriebsart;
  final String risikoprofil;
  final bool schichtbetrieb;

  const Betrieb({
    required this.id,
    required this.name,
    required this.kategorie,
    required this.betriebsart,
    required this.risikoprofil,
    required this.schichtbetrieb,
  });

  Betrieb copyWith({
    String? id,
    String? name,
    String? kategorie,
    String? betriebsart,
    String? risikoprofil,
    bool? schichtbetrieb,
  }) {
    return Betrieb(
      id: id ?? this.id,
      name: name ?? this.name,
      kategorie: kategorie ?? this.kategorie,
      betriebsart: betriebsart ?? this.betriebsart,
      risikoprofil: risikoprofil ?? this.risikoprofil,
      schichtbetrieb: schichtbetrieb ?? this.schichtbetrieb,
    );
  }
}