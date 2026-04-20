class Ruhetage {
  final String betriebId;   // bleibt String
  final List<int> ruhetage;

  Ruhetage({
    required this.betriebId,
    required this.ruhetage,
  });

  factory Ruhetage.fromJson(Map<String, dynamic> json) {
    return Ruhetage(
      betriebId: json['betrieb_id'],
      ruhetage: List<int>.from(json['ruhetage'] ?? []),
    );
  }
}