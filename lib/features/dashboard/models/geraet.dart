class Geraet {
  final String id;
  final String betriebId;
  final String name;
  final String? typ;
  final String? standort;
  final String? seriennummer;
  final int? reinigungsintervallTage;   // z.B. 7 = wöchentlich, 30 = monatlich
  final String? notizen;

  Geraet({
    required this.id,
    required this.betriebId,
    required this.name,
    this.typ,
    this.standort,
    this.seriennummer,
    this.reinigungsintervallTage,
    this.notizen,
  });

  factory Geraet.fromJson(Map<String, dynamic> json) {
    return Geraet(
      id: json['id']?.toString() ?? '',
      betriebId: json['betrieb_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      typ: json['typ'],
      standort: json['standort'],
      seriennummer: json['seriennummer'],
      reinigungsintervallTage: json['reinigungsintervall_tage'] as int?,
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
      if (reinigungsintervallTage != null) 'reinigungsintervall_tage': reinigungsintervallTage,
      if (notizen != null) 'notizen': notizen,
    };
  }
}