class Schicht {
  final String id;
  final String betriebId;
  final String name;
  final DateTime startZeit;      // nur Zeitanteil wird verwendet
  final DateTime endeZeit;       // nur Zeitanteil wird verwendet
  final String? beschreibung;
  final bool aktiv;

  Schicht({
    required this.id,
    required this.betriebId,
    required this.name,
    required this.startZeit,
    required this.endeZeit,
    this.beschreibung,
    this.aktiv = true,
  });

  factory Schicht.fromJson(Map<String, dynamic> json) {
    return Schicht(
      id: json['id']?.toString() ?? '',
      betriebId: json['betrieb_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      // Nur die Uhrzeit extrahieren
      startZeit: DateTime.parse('2024-01-01 ${json['start_zeit']}'),
      endeZeit: DateTime.parse('2024-01-01 ${json['ende_zeit']}'),
      beschreibung: json['beschreibung'],
      aktiv: json['aktiv'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    // Nur die Uhrzeit als String im Format HH:mm:ss senden
    final startStr = '${startZeit.hour.toString().padLeft(2, '0')}:${startZeit.minute.toString().padLeft(2, '0')}:00';
    final endStr = '${endeZeit.hour.toString().padLeft(2, '0')}:${endeZeit.minute.toString().padLeft(2, '0')}:00';

    return {
      'betrieb_id': betriebId,
      'name': name,
      'start_zeit': startStr,
      'ende_zeit': endStr,
      if (beschreibung != null) 'beschreibung': beschreibung,
      'aktiv': aktiv,
    };
  }
}