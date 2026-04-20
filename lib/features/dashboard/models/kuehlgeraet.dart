class Kuehlgeraet {
  final String id;
  final String betriebId;
  final String name;
  final String? typ;
  final String? standort;
  final String? seriennummer;
  final double? sollTemperatur;        // NEU
  final DateTime? letztePruefung;
  final DateTime? naechstePruefung;
  final String? notizen;

  Kuehlgeraet({
    required this.id,
    required this.betriebId,
    required this.name,
    this.typ,
    this.standort,
    this.seriennummer,
    this.sollTemperatur,
    this.letztePruefung,
    this.naechstePruefung,
    this.notizen,
  });

  factory Kuehlgeraet.fromJson(Map<String, dynamic> json) {
    return Kuehlgeraet(
      id: json['id']?.toString() ?? '',
      betriebId: json['betrieb_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      typ: json['typ'],
      standort: json['standort'],
      seriennummer: json['seriennummer'],
      sollTemperatur: json['soll_temperatur'] != null 
          ? (json['soll_temperatur'] as num).toDouble() 
          : null,
      letztePruefung: json['letzte_pruefung'] != null
          ? DateTime.tryParse(json['letzte_pruefung'].toString())
          : null,
      naechstePruefung: json['naechste_pruefung'] != null
          ? DateTime.tryParse(json['naechste_pruefung'].toString())
          : null,
      notizen: json['notizen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'betrieb_id': betriebId,
      'name': name,
      if (typ != null) 'typ': typ,
      if (standort != null) 'standort': standort,
      if (seriennummer != null) 'seriennummer': seriennummer,
      if (sollTemperatur != null) 'soll_temperatur': sollTemperatur,
      if (letztePruefung != null)
        'letzte_pruefung': letztePruefung!.toIso8601String().split('T').first,
      if (naechstePruefung != null)
        'naechste_pruefung': naechstePruefung!.toIso8601String().split('T').first,
      if (notizen != null) 'notizen': notizen,
    };
  }
}