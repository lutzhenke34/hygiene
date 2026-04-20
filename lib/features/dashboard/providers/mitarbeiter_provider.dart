class Mitarbeiter {
  final String id;
  final String betriebId;
  final String vorname;
  final String nachname;
  final String? kontakt;
  final String? rolle;
  final DateTime? letzteSchulung;
  final String? hygieneausweisUrl;

  final bool canManageHygiene;
  final bool canManageGeraete;
  final bool canManageSchichten;
  final bool canViewAllProtokolle;

  Mitarbeiter({
    required this.id,
    required this.betriebId,
    required this.vorname,
    required this.nachname,
    this.kontakt,
    this.rolle,
    this.letzteSchulung,
    this.hygieneausweisUrl,
    this.canManageHygiene = false,
    this.canManageGeraete = false,
    this.canManageSchichten = false,
    this.canViewAllProtokolle = true,
  });

  factory Mitarbeiter.fromJson(Map<String, dynamic> json) {
    return Mitarbeiter(
      id: json['id'] ?? '',
      betriebId: json['betrieb_id'] ?? '',
      vorname: json['vorname'] ?? '',
      nachname: json['nachname'] ?? '',
      kontakt: json['kontakt'],
      rolle: json['rolle'],
      letzteSchulung: json['letzte_schulung'] != null 
          ? DateTime.parse(json['letzte_schulung']) 
          : null,
      hygieneausweisUrl: json['hygieneausweis_url'],
      canManageHygiene: json['can_manage_hygiene'] ?? false,
      canManageGeraete: json['can_manage_geraete'] ?? false,
      canManageSchichten: json['can_manage_schichten'] ?? false,
      canViewAllProtokolle: json['can_view_all_protokolle'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'betrieb_id': betriebId,
      'vorname': vorname,
      'nachname': nachname,
      'kontakt': kontakt,
      'rolle': rolle,
      'letzte_schulung': letzteSchulung?.toIso8601String(),
      'hygieneausweis_url': hygieneausweisUrl,
      'can_manage_hygiene': canManageHygiene,
      'can_manage_geraete': canManageGeraete,
      'can_manage_schichten': canManageSchichten,
      'can_view_all_protokolle': canViewAllProtokolle,
    };

    if (id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }
}