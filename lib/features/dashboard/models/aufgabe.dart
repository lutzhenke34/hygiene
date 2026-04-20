class Aufgabe {
  final String id;
  final String betriebId;
  final String titel;
  final String? beschreibung;
  final String? rolle;
  final DateTime? faelligBis;
  final int? wiederholungsIntervallTage;
  final String? schichtId;           // ← NEU
  final bool erledigt;

  Aufgabe({
    required this.id,
    required this.betriebId,
    required this.titel,
    this.beschreibung,
    this.rolle,
    this.faelligBis,
    this.wiederholungsIntervallTage,
    this.schichtId,                    // ← NEU
    this.erledigt = false,
  });

  factory Aufgabe.fromJson(Map<String, dynamic> json) {
    return Aufgabe(
      id: json['id']?.toString() ?? '',
      betriebId: json['betrieb_id']?.toString() ?? '',
      titel: json['titel']?.toString() ?? '',
      beschreibung: json['beschreibung'],
      rolle: json['rolle'],
      faelligBis: json['faellig_bis'] != null 
          ? DateTime.tryParse(json['faellig_bis'].toString()) 
          : null,
      wiederholungsIntervallTage: json['wiederholungs_intervall_tage'] as int?,
      schichtId: json['schicht_id'],                    // ← NEU
      erledigt: json['erledigt'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'betrieb_id': betriebId,
      'titel': titel,
      if (beschreibung != null) 'beschreibung': beschreibung,
      if (rolle != null) 'rolle': rolle,
      if (faelligBis != null) 'faellig_bis': faelligBis!.toIso8601String().split('T')[0],
      if (wiederholungsIntervallTage != null) 'wiederholungs_intervall_tage': wiederholungsIntervallTage,
      if (schichtId != null) 'schicht_id': schichtId,     // ← NEU
      'erledigt': erledigt,
    };
  }
}