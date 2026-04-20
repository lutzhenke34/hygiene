enum HygieneAufgabeTyp {
  individuell,
  temperaturprotokoll,
  geraete,
}

class HygieneAufgabe {
  final String id;
  final String betriebId;
  final HygieneAufgabeTyp typ;
  final String titel;
  final String? beschreibung;
  final String? kuehlgeraetId;
  final String? geraetId;
  final String? rolle;
  final DateTime? faelligBis;
  final int? wiederholungsIntervall;
  final String? protokollName;
  final String? schichtId;           // ← NEU: Zuordnung zu einer Schicht (null = alle Schichten)
  final bool erledigt;

  HygieneAufgabe({
    required this.id,
    required this.betriebId,
    required this.typ,
    required this.titel,
    this.beschreibung,
    this.kuehlgeraetId,
    this.geraetId,
    this.rolle,
    this.faelligBis,
    this.wiederholungsIntervall,
    this.protokollName,
    this.schichtId,                    // ← NEU
    this.erledigt = false,
  });

  factory HygieneAufgabe.fromJson(Map<String, dynamic> json) {
    return HygieneAufgabe(
      id: json['id']?.toString() ?? '',
      betriebId: json['betrieb_id']?.toString() ?? '',
      typ: HygieneAufgabeTyp.values.byName(
          json['typ']?.toString().toLowerCase() ?? 'individuell'),
      titel: json['titel']?.toString() ?? '',
      beschreibung: json['beschreibung'],
      kuehlgeraetId: json['kuehlgeraet_id'],
      geraetId: json['geraet_id'],
      rolle: json['rolle'],
      faelligBis: json['faellig_bis'] != null
          ? DateTime.tryParse(json['faellig_bis'].toString())
          : null,
      wiederholungsIntervall: json['wiederholungs_intervall'],
      protokollName: json['protokoll_name'],
      schichtId: json['schicht_id'],                    // ← NEU
      erledigt: json['erledigt'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'betrieb_id': betriebId,
      'typ': typ.name.toUpperCase(),
      'titel': titel,
      if (beschreibung != null) 'beschreibung': beschreibung,
      if (kuehlgeraetId != null) 'kuehlgeraet_id': kuehlgeraetId,
      if (geraetId != null) 'geraet_id': geraetId,
      if (rolle != null) 'rolle': rolle,
      if (faelligBis != null) 'faellig_bis': faelligBis!.toIso8601String().split('T')[0],
      if (wiederholungsIntervall != null) 'wiederholungs_intervall': wiederholungsIntervall,
      if (protokollName != null) 'protokoll_name': protokollName,
      if (schichtId != null) 'schicht_id': schichtId,     // ← NEU
      'erledigt': erledigt,
    };
  }
}