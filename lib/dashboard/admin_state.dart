class AdminState {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> betriebe = [
    {
      "name": "Restaurant A",
      "kategorie": "Gastronomie",
      "betriebsart": "Restaurant",
      "risikoprofil": "gastro_standard",
      "schichtbetrieb": false,
      "frueh_start": "",
      "frueh_ende": "",
      "spaet_start": "",
      "spaet_ende": "",
      "nacht_start": "",
      "nacht_ende": "",
      "geraete": [],
      "mitarbeiter": [],
      "aufgaben": [],
      "kuehlgeraete": [], // Wichtig für Kühlgeräte!
    }
  ];

  Map<String, dynamic>? selectedBetrieb;

  AdminState() {
    selectedBetrieb = betriebe.first;
  }

  void addBetrieb(Map<String, dynamic> betrieb) {
    // Sicherstellen, dass alle Listen existieren
    betrieb["geraete"] = betrieb["geraete"] ?? [];
    betrieb["mitarbeiter"] = betrieb["mitarbeiter"] ?? [];
    betrieb["aufgaben"] = betrieb["aufgaben"] ?? [];
    betrieb["kuehlgeraete"] = betrieb["kuehlgeraete"] ?? [];

    betriebe.add(betrieb);
    selectedBetrieb = betrieb;
  }

  void addGeraet(Map<String, dynamic> geraet) {
    selectedBetrieb!["geraete"].add(geraet);
  }

  void addMitarbeiter(Map<String, dynamic> mitarbeiter) {
    selectedBetrieb!["mitarbeiter"].add(mitarbeiter);
  }

  void addAufgabe(Map<String, dynamic> aufgabe) {
    selectedBetrieb!["aufgaben"].add(aufgabe);
  }

  void addKuehlgeraet(Map<String, dynamic> kuehlgeraet) {
    selectedBetrieb!["kuehlgeraete"].add(kuehlgeraet);
  }
}