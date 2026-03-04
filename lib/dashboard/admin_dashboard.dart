import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/admin_providers.dart'; // Passe den Import-Pfad an

class AdminDashboard extends ConsumerStatefulWidget {
 const AdminDashboard({super.key});

 @override
 ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
 int _selectedIndex = 0;

 // ── Statische Konfigurationen ─────────────────────────────────────────────
 final Map<String, List<Map<String, String>>> betriebsarten = {
 "Gastronomie": [
 {"name": "Restaurant", "risiko": "gastro_standard"},
 {"name": "Café", "risiko": "gastro_standard"},
 {"name": "Imbiss", "risiko": "gastro_standard"},
 {"name": "Bar", "risiko": "gastro_light"},
 ],
 "Produktion": [
 {"name": "Bäckerei", "risiko": "produktion"},
 {"name": "Metzgerei", "risiko": "produktion_high"},
 ],
 "Handel": [
 {"name": "Supermarkt", "risiko": "handel"},
 {"name": "Bioladen", "risiko": "handel"},
 ],
 };

 final Map<String, double> kuehlgeraeteTypen = {
 "Kühlschrank": 4.0,
 "Tiefkühler": -18.0,
 "Vorkühler": 2.0,
 "Kühlzelle": 4.0,
 "Sonstiges": 0.0,
 };

 final List<String> vordefinierteRollen = [
 "Betriebsleiter",
 "Schichtleiter",
 "Küche",
 "Service",
 "Verkauf",
 "Lager",
 "Reinigung",
 "Sonstiges",
 ];

 final Map<String, List<Map<String, dynamic>>> vordefinierteGeraete = {
 "Gastronomie": [
 {"name": "Schneidbrett", "intervall": 1},
 {"name": "Messer", "intervall": 1},
 {"name": "Arbeitsfläche", "intervall": 1},
 {"name": "Spülmaschine", "intervall": 7},
 {"name": "Kochfeld", "intervall": 1},
 ],
 "Produktion": [
 {"name": "Teigmaschine", "intervall": 7},
 {"name": "Ofen", "intervall": 30},
 {"name": "Schneidemaschine", "intervall": 7},
 {"name": "Kühlband", "intervall": 30},
 ],
 "Handel": [
 {"name": "Regalfläche", "intervall": 7},
 {"name": "Kühltheke", "intervall": 1},
 {"name": "Waage", "intervall": 30},
 {"name": "Kassensystem", "intervall": 30},
 ],
 };

 // ────────────────────────────────────────────────────────────────────────────
 // Hilfsmethoden für Zeitfelder – MÜSSEN VOR dem Aufruf stehen!
 // ────────────────────────────────────────────────────────────────────────────

 Widget _buildTimeField({
 required String label,
 required String value,
 required VoidCallback onTap,
 }) {
 return GestureDetector(
 onTap: onTap,
 child: InputDecorator(
 decoration: InputDecoration(
 labelText: label,
 border: const OutlineInputBorder(),
 ),
 child: Text(
 value.isEmpty ? "Nicht angegeben" : value,
 style: TextStyle(color: value.isEmpty ? Colors.grey : null),
 ),
 ),
 );
 }

 Future<String?> _selectTime(BuildContext context, String current) async {
 final initialTime = TimeOfDay.now();
 TimeOfDay? initial;

 if (current.isNotEmpty && current.contains(':')) {
 try {
 final parts = current.split(':');
 initial = TimeOfDay(
 hour: int.parse(parts[0]),
 minute: int.parse(parts[1]),
 );
 } catch (_) {
 initial = initialTime;
 }
 } else {
 initial = initialTime;
 }

 final picked = await showTimePicker(
 context: context,
 initialTime: initial,
 );

 if (picked == null) return null;
 return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
 }

 @override
 Widget build(BuildContext context) {
 final betriebeAsync = ref.watch(betriebeProvider);
 final selectedBetrieb = ref.watch(selectedBetriebProvider);
 final betriebId = selectedBetrieb?['id'] as String?;

 return Scaffold(
 appBar: AppBar(
 title: const Text("Admin – Betriebsverwaltung"),
 actions: [
 if (selectedBetrieb != null)
 Padding(
 padding: const EdgeInsets.only(right: 16),
 child: Chip(
 avatar: const Icon(Icons.business, size: 18),
 label: Text(selectedBetrieb['name'] ?? 'Unbenannt'),
 backgroundColor: Colors.blue.shade50,
 ),
 ),
 ],
 ),
 body: Row(
 children: [
 NavigationRail(
 selectedIndex: _selectedIndex,
 onDestinationSelected: (index) => setState(() => _selectedIndex = index),
 labelType: NavigationRailLabelType.all,
 backgroundColor: Colors.grey.shade50,
 elevation: 1,
 destinations: const [
 NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), label: Text("Übersicht")),
 NavigationRailDestination(icon: Icon(Icons.clean_hands_outlined), label: Text("Hygiene")),
 NavigationRailDestination(icon: Icon(Icons.assignment_outlined), label: Text("Aufgaben")),
 NavigationRailDestination(icon: Icon(Icons.ac_unit_outlined), label: Text("Kühlgeräte")),
 NavigationRailDestination(icon: Icon(Icons.build_outlined), label: Text("Geräte")),
 NavigationRailDestination(icon: Icon(Icons.people_outline), label: Text("Mitarbeiter")),
 ],
 ),
 const VerticalDivider(width: 1, thickness: 1),
 Expanded(
 child: betriebeAsync.when(
 loading: () => const Center(child: CircularProgressIndicator()),
 error: (err, stack) => Center(
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 const Icon(Icons.error_outline, size: 72, color: Colors.red),
 const SizedBox(height: 24),
 Text("Fehler beim Laden:\n$err", textAlign: TextAlign.center),
 const SizedBox(height: 16),
 OutlinedButton(
 onPressed: () => ref.invalidate(betriebeProvider),
 child: const Text("Neu laden"),
 ),
 ],
 ),
 ),
 data: (_) {
 if (selectedBetrieb == null || selectedBetrieb.isEmpty) {
 return _buildNoBetriebSelected();
 }
 return _buildContent(selectedBetrieb, betriebId);
 },
 ),
 ),
 ],
 ),
 floatingActionButton: _buildFloatingActionButton(betriebId),
 );
 }

 Widget _buildNoBetriebSelected() {
 return Center(
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(Icons.business_center_outlined, size: 96, color: Colors.grey.shade400),
 const SizedBox(height: 32),
 const Text(
 "Kein Betrieb ausgewählt",
 style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
 ),
 const SizedBox(height: 16),
 const Text(
 "Wähle einen bestehenden Betrieb aus oder lege einen neuen an.",
 style: TextStyle(fontSize: 16, color: Colors.grey),
 ),
 const SizedBox(height: 40),
 FilledButton.icon(
 icon: const Icon(Icons.add_business_rounded),
 label: const Text("Neuen Betrieb anlegen"),
 style: FilledButton.styleFrom(
 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
 ),
 onPressed: _showAddBetriebDialog,
 ),
 ],
 ),
 );
 }

 Widget _buildContent(Map<String, dynamic> betrieb, String? betriebId) {
 return IndexedStack(
 index: _selectedIndex,
 children: [
 _buildOverview(betrieb, betriebId),
 const Center(child: Text("Hygiene – bald verfügbar", style: TextStyle(fontSize: 36, color: Colors.grey))),
 const Center(child: Text("Aufgaben – bald verfügbar", style: TextStyle(fontSize: 36, color: Colors.grey))),
 _buildKuehlgeraete(betriebId),
 _buildGeraete(betriebId),
 _buildMitarbeiter(betriebId),
 ],
 );
 }

 Widget? _buildFloatingActionButton(String? betriebId) {
 if (betriebId == null) return null;

 switch (_selectedIndex) {
 case 3:
 return FloatingActionButton.extended(
 heroTag: 'fab_kuehl',
 icon: const Icon(Icons.add),
 label: const Text("Kühlgerät"),
 onPressed: () => _showAddKuehlgeraetDialog(betriebId),
 );
 case 4:
 return FloatingActionButton.extended(
 heroTag: 'fab_geraet',
 icon: const Icon(Icons.add),
 label: const Text("Gerät"),
 onPressed: () => _showAddGeraetDialog(betriebId),
 );
 case 5:
 return FloatingActionButton.extended(
 heroTag: 'fab_mitarbeiter',
 icon: const Icon(Icons.person_add_alt_1),
 label: const Text("Mitarbeiter"),
 onPressed: () => _showAddMitarbeiterDialog(betriebId),
 );
 default:
 return null;
 }
 }

 // ────────────────────────────────────────────────────────────────────────────
 // Übersicht
 // ────────────────────────────────────────────────────────────────────────────

 Widget _buildOverview(Map<String, dynamic> b, String? betriebId) {
 final mitarbeiterAsync = ref.watch(mitarbeiterProvider(betriebId));
 final kuehlAsync = ref.watch(kuehlgeraeteProvider(betriebId));
 final geraeteAsync = ref.watch(geraeteProvider(betriebId));

 return mitarbeiterAsync.when(
 data: (mitarbeiter) => kuehlAsync.when(
 data: (kuehl) => geraeteAsync.when(
 data: (geraete) {
 final mitarbeiterVorOrt = mitarbeiter.length; // Dummy – später echte Logik
 return SingleChildScrollView(
 padding: const EdgeInsets.all(24),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 b['name'] ?? "Unbenannter Betrieb",
 style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
 ),
 const SizedBox(height: 8),
 Text(
 "${b['kategorie'] ?? '?'} • ${b['betriebsart'] ?? '?'} • Risiko: ${b['risikoprofil'] ?? '?'}",
 style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
 ),
 const SizedBox(height: 40),
 Wrap(
 spacing: 24,
 runSpacing: 24,
 children: [
 _StatCard(
 title: "Mitarbeiter vor Ort",
 value: "$mitarbeiterVorOrt / ${mitarbeiter.length}",
 icon: Icons.people,
 color: Colors.blue,
 ),
 _StatCard(
 title: "Offene Aufgaben",
 value: "5",
 icon: Icons.assignment_late,
 color: Colors.orange,
 ),
 _StatCard(
 title: "Offene Hygiene",
 value: "3",
 icon: Icons.cleaning_services,
 color: Colors.red,
 ),
 ],
 ),
 const SizedBox(height: 48),
 FilledButton.icon(
 icon: const Icon(Icons.description),
 label: const Text("Alle HACCP-Protokolle anzeigen"),
 style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
 onPressed: () {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text("Noch nicht implementiert")),
 );
 },
 ),
 ],
 ),
 );
 },
 loading: () => const Center(child: CircularProgressIndicator()),
 error: (e, _) => Center(child: Text("Fehler: $e")),
 ),
 loading: () => const Center(child: CircularProgressIndicator()),
 error: (e, _) => Center(child: Text("Fehler: $e")),
 ),
 loading: () => const Center(child: CircularProgressIndicator()),
 error: (e, _) => Center(child: Text("Fehler: $e")),
 );
 }

 Widget _StatCard({
 required String title,
 required String value,
 required IconData icon,
 required Color color,
 }) {
 return Card(
 elevation: 3,
 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
 child: SizedBox(
 width: 260,
 child: Padding(
 padding: const EdgeInsets.all(20),
 child: Column(
 children: [
 Icon(icon, size: 48, color: color),
 const SizedBox(height: 16),
 Text(title, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
 const SizedBox(height: 12),
 Text(
 value,
 style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
 ),
 ],
 ),
 ),
 ),
 );
 }

 // ────────────────────────────────────────────────────────────────────────────
 // Kühlgeräte – Beispiel-Implementierung (erweitere bei Bedarf)
 // ────────────────────────────────────────────────────────────────────────────

 Widget _buildKuehlgeraete(String? betriebId) {
  if (betriebId == null) return const SizedBox.shrink();

  final asyncData = ref.watch(kuehlgeraeteProvider(betriebId));

  return asyncData.when(
    data: (items) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Kühlgeräte", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text("Noch keine Kühlgeräte vorhanden"))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final g = items[i];
                      final temp = g['akt_temp'] ?? g['soll_temp'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.ac_unit, color: Colors.blue, size: 36),
                          title: Text(g['name'] ?? "Unbenannt", style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("Typ: ${g['typ']} • Soll: ${g['soll_temp']} °C"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _editAktuelleTemperatur(g['id'], temp, betriebId),
                                child: Chip(
                                  label: Text("$temp °C"),
                                  backgroundColor: _getTempColor(temp, g['soll_temp']), // ← hier wird die Methode aufgerufen
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteKuehlgeraet(g['id'], betriebId, g['name'] ?? 'Gerät'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => Center(child: Text("Fehler: $e")),
  );
}

// Die fehlende Methode – HIER einfügen!
Color _getTempColor(dynamic akt, dynamic soll) {
  if (akt == null || soll == null) return Colors.grey.shade200;

  final diff = (akt as num) - (soll as num);

  if (diff.abs() < 1) return Colors.green.shade100;
  if (diff.abs() < 3) return Colors.orange.shade100;
  return Colors.red.shade100;
}
 

 Future<void> _showAddKuehlgeraetDialog(String? betriebId) async {
 // Deine Implementierung hier – als Platzhalter
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text("Kühlgerät hinzufügen – noch nicht implementiert")),
 );
 }

 Future<void> _editAktuelleTemperatur(String id, dynamic current, String betriebId) async {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text("Temperatur bearbeiten – noch nicht implementiert")),
 );
 }

 Future<void> _deleteKuehlgeraet(String id, String betriebId, String name) async {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text("Kühlgerät löschen – noch nicht implementiert")),
 );
 }

 // ────────────────────────────────────────────────────────────────────────────
 // Geräte – Vollständig implementiert
 // ────────────────────────────────────────────────────────────────────────────

 Widget _buildGeraete(String? betriebId) {
 if (betriebId == null) return const SizedBox.shrink();

 final geraeteAsync = ref.watch(geraeteProvider(betriebId));

 return geraeteAsync.when(
 data: (items) => Padding(
 padding: const EdgeInsets.all(24),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 const Text("Geräte", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
 const Spacer(),
 ElevatedButton.icon(
 icon: const Icon(Icons.add),
 label: const Text("Gerät hinzufügen"),
 onPressed: () => _showAddGeraetDialog(betriebId),
 ),
 ],
 ),
 const SizedBox(height: 20),
 Expanded(
 child: items.isEmpty
 ? const Center(child: Text("Noch keine Geräte vorhanden"))
 : ListView.builder(
 itemCount: items.length,
 itemBuilder: (context, i) {
 final g = items[i];
 final intervall = g['intervall_tage'] as int? ?? 0;
 return Card(
 margin: const EdgeInsets.only(bottom: 12),
 child: ListTile(
 leading: const Icon(Icons.build, color: Colors.orange, size: 36),
 title: Text(g['name'] ?? "Unbenannt", style: const TextStyle(fontWeight: FontWeight.w600)),
 subtitle: Text("Reinigungsintervall: $intervall Tage"),
 trailing: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 GestureDetector(
 onTap: () => _editIntervall(g['id'], intervall, betriebId),
 child: Chip(
 label: Text("$intervall Tage"),
 backgroundColor: Colors.orange.shade100,
 ),
 ),
 const SizedBox(width: 16),
 IconButton(
 icon: const Icon(Icons.delete_outline, color: Colors.red),
 onPressed: () => _deleteGeraet(g['id'], betriebId, g['name'] ?? 'Gerät'),
 ),
 ],
 ),
 ),
 );
 },
 ),
 ),
 ],
 ),
 ),
 loading: () => const Center(child: CircularProgressIndicator()),
 error: (e, _) => Center(child: Text("Fehler: $e")),
 );
 }

 Future<void> _showAddGeraetDialog(String? betriebId) async {
 if (betriebId == null) return;

 final selectedBetrieb = ref.read(selectedBetriebProvider);
 String? kategorie = selectedBetrieb?['kategorie'] as String?;
 List<Map<String, dynamic>> vorlagen = kategorie != null && vordefinierteGeraete.containsKey(kategorie)
 ? vordefinierteGeraete[kategorie]!
 : [];

 String? vorlageName;
 int intervall = 7;
 final nameController = TextEditingController();

 await showDialog(
 context: context,
 builder: (_) => AlertDialog(
 title: const Text("Neues Gerät"),
 content: StatefulBuilder(
 builder: (context, setInner) {
 return Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 if (vorlagen.isNotEmpty)
 DropdownButtonFormField<String?>(
 value: vorlageName,
 decoration: const InputDecoration(labelText: "Vordefiniertes Gerät"),
 items: [
 ...vorlagen.map((g) => DropdownMenuItem<String?>(
 value: g["name"] as String?,
 child: Text("${g["name"]} (${g["intervall"]} Tage)"),
 )),
 const DropdownMenuItem(value: null, child: Text("Freies Gerät")),
 ],
 onChanged: (value) {
 setInner(() {
 vorlageName = value;
 if (value != null) {
 final vorlage = vorlagen.firstWhere((g) => g["name"] == value);
 intervall = vorlage["intervall"] as int;
 nameController.text = value;
 } else {
 intervall = 7;
 nameController.clear();
 }
 });
 },
 ),
 const SizedBox(height: 16),
 TextField(
 controller: nameController,
 decoration: const InputDecoration(labelText: "Name des Geräts"),
 ),
 const SizedBox(height: 16),
 TextField(
 keyboardType: TextInputType.number,
 decoration: const InputDecoration(
 labelText: "Reinigungsintervall (Tage)",
 suffixText: "Tage",
 ),
 controller: TextEditingController(text: intervall.toString()),
 onChanged: (v) {
 intervall = int.tryParse(v) ?? intervall;
 },
 ),
 ],
 );
 },
 ),
 actions: [
 TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
 FilledButton(
 child: const Text("Hinzufügen"),
 onPressed: () async {
 if (nameController.text.trim().isEmpty) return;

 final neu = {
 "betrieb_id": betriebId,
 "name": nameController.text.trim(),
 "intervall_tage": intervall,
 };

 try {
 await ref.read(supabaseProvider).from('geraete').insert(neu);
 ref.invalidate(geraeteProvider(betriebId));
 ref.refresh(geraeteProvider(betriebId));
 if (context.mounted) Navigator.pop(context);
 } catch (e) {
 if (context.mounted) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text("Fehler beim Anlegen: $e")),
 );
 }
 }
 },
 ),
 ],
 ),
 );
 }

 Future<void> _editIntervall(String id, int currentIntervall, String? betriebId) async {
 if (betriebId == null) return;

 final controller = TextEditingController(text: currentIntervall.toString());

 await showDialog(
 context: context,
 builder: (_) => AlertDialog(
 title: const Text("Reinigungsintervall bearbeiten"),
 content: TextField(
 controller: controller,
 keyboardType: TextInputType.number,
 decoration: const InputDecoration(suffixText: "Tage"),
 ),
 actions: [
 TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
 FilledButton(
 child: const Text("Speichern"),
 onPressed: () async {
 final newIntervall = int.tryParse(controller.text);
 if (newIntervall != null && newIntervall > 0) {
 try {
 await ref.read(supabaseProvider).from('geraete').update({'intervall_tage': newIntervall}).eq('id', id);
 ref.invalidate(geraeteProvider(betriebId));
 ref.refresh(geraeteProvider(betriebId));
 if (context.mounted) Navigator.pop(context);
 } catch (e) {
 if (context.mounted) {
 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e")));
 }
 }
 } else {
 if (context.mounted) {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text("Bitte eine Zahl > 0 eingeben")),
 );
 }
 }
 },
 ),
 ],
 ),
 );
 }

 Future<void> _deleteGeraet(String id, String? betriebId, String name) async {
 if (betriebId == null) return;

 final confirmed = await showDialog<bool>(
 context: context,
 builder: (_) => AlertDialog(
 title: const Text("Wirklich löschen?"),
 content: Text("Gerät „$name“ wird unwiderruflich entfernt."),
 actions: [
 TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
 TextButton(
 style: TextButton.styleFrom(foregroundColor: Colors.red),
 onPressed: () => Navigator.pop(context, true),
 child: const Text("Löschen"),
 ),
 ],
 ),
 );

 if (confirmed != true) return;

 try {
 await ref.read(supabaseProvider).from('geraete').delete().eq('id', id);
 ref.invalidate(geraeteProvider(betriebId));
 ref.refresh(geraeteProvider(betriebId));
 if (context.mounted) {
 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name gelöscht")));
 }
 } catch (e) {
 if (context.mounted) {
 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler beim Löschen: $e")));
 }
 }
 }

 // ────────────────────────────────────────────────────────────────────────────
 // Mitarbeiter – mit Upload
 // ────────────────────────────────────────────────────────────────────────────

 Widget _buildMitarbeiter(String? betriebId) {
 if (betriebId == null) return const SizedBox.shrink();

 final mitarbeiterAsync = ref.watch(mitarbeiterProvider(betriebId));

 return mitarbeiterAsync.when(
 data: (mitarbeiter) => Padding(
 padding: const EdgeInsets.all(24),
 child: Column(
 children: [
 Row(
 children: [
 const Text("Mitarbeiter", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
 const Spacer(),
 ElevatedButton.icon(
 icon: const Icon(Icons.add),
 label: const Text("Mitarbeiter hinzufügen"),
 onPressed: () => _showAddMitarbeiterDialog(betriebId),
 ),
 ],
 ),
 const SizedBox(height: 20),
 Expanded(
 child: mitarbeiter.isEmpty
 ? const Center(child: Text("Noch keine Mitarbeiter angelegt"))
 : ListView.builder(
 itemCount: mitarbeiter.length,
 itemBuilder: (context, index) {
 final m = mitarbeiter[index];
 final String? url = m["hygieneausweis"] as String?;
 return Card(
 margin: const EdgeInsets.only(bottom: 12),
 child: ListTile(
 leading: const Icon(Icons.person, color: Colors.indigo, size: 32),
 title: Text("${m["vorname"]} ${m["nachname"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
 subtitle: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text("Rolle: ${m["rolle"]}"),
 Text("Kontakt: ${m["kontakt"] ?? "—"}"),
 if (url != null)
 const Text("Hygieneausweis: vorhanden", style: TextStyle(color: Colors.green)),
 Text("Letzte Schulung: ${m["letzte_schulung"] ?? "Nicht angegeben"}"),
 ],
 ),
 trailing: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 IconButton(
 icon: const Icon(Icons.edit, color: Colors.blue),
 onPressed: () => _showEditMitarbeiterDialog(m["id"], m, betriebId),
 ),
 IconButton(
 icon: const Icon(Icons.delete, color: Colors.red),
 onPressed: () => _deleteMitarbeiter(m["id"], betriebId),
 ),
 ],
 ),
 ),
 );
 },
 ),
 ),
 ],
 ),
 ),
 loading: () => const Center(child: CircularProgressIndicator()),
 error: (e, _) => Center(child: Text("Fehler beim Laden: $e")),
 );
 }

 Future<void> _showAddMitarbeiterDialog(String? betriebId) async {
 if (betriebId == null) return;

 final vornameCtrl = TextEditingController();
 final nachnameCtrl = TextEditingController();
 final kontaktCtrl = TextEditingController();
 String rolle = vordefinierteRollen.first;
 String freieRolle = "";
 DateTime? letzteSchulung;
 PlatformFile? selectedFile;
 String displayName = "Noch kein Dokument ausgewählt";
 bool uploading = false;

 await showDialog(
 context: context,
 builder: (ctx) {
 return StatefulBuilder(
 builder: (context, setInner) {
 return AlertDialog(
 title: const Text("Neuer Mitarbeiter"),
 content: SingleChildScrollView(
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 TextField(controller: vornameCtrl, decoration: const InputDecoration(labelText: "Vorname")),
 const SizedBox(height: 12),
 TextField(controller: nachnameCtrl, decoration: const InputDecoration(labelText: "Nachname")),
 const SizedBox(height: 12),
 TextField(
 controller: kontaktCtrl,
 decoration: const InputDecoration(labelText: "Telefon / E-Mail"),
 keyboardType: TextInputType.emailAddress,
 ),
 const SizedBox(height: 16),
 DropdownButtonFormField<String>(
 value: rolle,
 decoration: const InputDecoration(labelText: "Rolle"),
 items: vordefinierteRollen.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
 onChanged: (v) => setInner(() => rolle = v!),
 ),
 if (rolle == "Sonstiges") ...[
 const SizedBox(height: 12),
 TextField(
 onChanged: (v) => setInner(() => freieRolle = v),
 decoration: const InputDecoration(labelText: "Freie Rolle"),
 ),
 ],
 const SizedBox(height: 16),
 ListTile(
 title: Text(
 "Letzte Schulung: ${letzteSchulung == null ? "—" : "${letzteSchulung!.day}.${letzteSchulung!.month}.${letzteSchulung!.year}"}",
 ),
 trailing: const Icon(Icons.calendar_today),
 onTap: () async {
 final d = await showDatePicker(
 context: context,
 initialDate: letzteSchulung ?? DateTime.now(),
 firstDate: DateTime(2000),
 lastDate: DateTime.now(),
 );
 if (d != null) setInner(() => letzteSchulung = d);
 },
 ),
 const SizedBox(height: 12),
 ListTile(
 leading: uploading
 ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
 : const Icon(Icons.upload_file, color: Colors.blue),
 title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
 subtitle: selectedFile != null ? Text("${(selectedFile!.size / 1024).toStringAsFixed(1)} KB") : null,
 onTap: uploading
 ? null
 : () async {
 final res = await FilePicker.platform.pickFiles(
 type: FileType.custom,
 allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
 );
 if (res != null && res.files.isNotEmpty) {
 setInner(() {
 selectedFile = res.files.first;
 displayName = selectedFile!.name;
 });
 }
 },
 ),
 ],
 ),
 ),
 actions: [
 TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Abbrechen")),
 FilledButton(
 child: const Text("Speichern"),
 onPressed: uploading
 ? null
 : () async {
 if (vornameCtrl.text.trim().isEmpty || nachnameCtrl.text.trim().isEmpty) return;

 final neueRolle = rolle == "Sonstiges" ? freieRolle.trim() : rolle;
 String? hygieneUrl;

 if (selectedFile != null && selectedFile!.bytes != null) {
 setInner(() => uploading = true);
 try {
 final bytes = selectedFile!.bytes!;
 final ext = selectedFile!.extension ?? 'pdf';
 final path = 'mitarbeiter/${vornameCtrl.text.trim()}_${nachnameCtrl.text.trim()}_${DateTime.now().millisecondsSinceEpoch}.$ext';

 final supabase = ref.read(supabaseProvider);
 await supabase.storage.from('hygieneausweise').uploadBinary(path, bytes);
 hygieneUrl = supabase.storage.from('hygieneausweise').getPublicUrl(path);
 } catch (e) {
 if (ctx.mounted) {
 ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Upload fehlgeschlagen: $e")));
 }
 setInner(() => uploading = false);
 return;
 }
 }

 final neu = {
 "betrieb_id": betriebId,
 "vorname": vornameCtrl.text.trim(),
 "nachname": nachnameCtrl.text.trim(),
 "kontakt": kontaktCtrl.text.trim(),
 "rolle": neueRolle.isEmpty ? "Sonstiges" : neueRolle,
 "letzte_schulung": letzteSchulung?.toIso8601String(),
 "hygieneausweis": hygieneUrl,
 };

 try {
 await ref.read(supabaseProvider).from('mitarbeiter').insert(neu);
 ref.invalidate(mitarbeiterProvider(betriebId));
 ref.refresh(mitarbeiterProvider(betriebId));
 if (ctx.mounted) Navigator.pop(ctx);
 } catch (e) {
 if (ctx.mounted) {
 ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Speichern fehlgeschlagen: $e")));
 }
 } finally {
 setInner(() => uploading = false);
 }
 },
 ),
 ],
 );
 },
 );
 },
 );
 }

 Future<void> _showEditMitarbeiterDialog(String id, Map<String, dynamic> m, String? betriebId) async {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text("Bearbeiten noch nicht implementiert")),
 );
 }

 Future<void> _deleteMitarbeiter(String id, String? betriebId) async {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text("Löschen noch nicht implementiert")),
 );
 }

 // ────────────────────────────────────────────────────────────────────────────
 // Betrieb anlegen Dialog – mit Schichtzeiten
 // ────────────────────────────────────────────────────────────────────────────

 void _showAddBetriebDialog() async {
 final nameController = TextEditingController();
 String selectedKategorie = betriebsarten.keys.first;
 Map<String, String> selectedArt = betriebsarten[selectedKategorie]!.first;
 bool schichtbetrieb = false;

 String fruehStart = "";
 String fruehEnde = "";
 String spaetStart = "";
 String spaetEnde = "";
 String nachtStart = "";
 String nachtEnde = "";

 await showDialog(
 context: context,
 builder: (dialogContext) {
 return StatefulBuilder(
 builder: (context, setInnerState) {
 return AlertDialog(
 title: const Text("Neuen Betrieb anlegen"),
 content: SingleChildScrollView(
 child: Column(
 mainAxisSize: MainAxisSize.min,
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 TextField(
 controller: nameController,
 decoration: const InputDecoration(
 labelText: "Betriebsname *",
 border: OutlineInputBorder(),
 ),
 autofocus: true,
 ),
 const SizedBox(height: 16),
 DropdownButtonFormField<String>(
 value: selectedKategorie,
 decoration: const InputDecoration(
 labelText: "Branche",
 border: OutlineInputBorder(),
 ),
 items: betriebsarten.keys
 .map((k) => DropdownMenuItem(value: k, child: Text(k)))
 .toList(),
 onChanged: (value) {
 setInnerState(() {
 selectedKategorie = value!;
 selectedArt = betriebsarten[selectedKategorie]!.first;
 });
 },
 ),
 const SizedBox(height: 16),
 DropdownButtonFormField<String>(
 value: selectedArt["name"],
 decoration: const InputDecoration(
 labelText: "Betriebsart *",
 border: OutlineInputBorder(),
 ),
 items: betriebsarten[selectedKategorie]!.map((art) {
 return DropdownMenuItem(
 value: art["name"],
 child: Text("${art["name"]} (${art["risiko"]})"),
 );
 }).toList(),
 onChanged: (value) {
 setInnerState(() {
 selectedArt = betriebsarten[selectedKategorie]!
 .firstWhere((art) => art["name"] == value);
 });
 },
 ),
 const SizedBox(height: 24),
 SwitchListTile(
 title: const Text("Schichtbetrieb"),
 subtitle: const Text("Mit Früh-, Spät- und Nachtschicht"),
 value: schichtbetrieb,
 onChanged: (v) => setInnerState(() => schichtbetrieb = v),
 ),
 if (schichtbetrieb) ...[
 const SizedBox(height: 16),
 const Text("Schichtzeiten", style: TextStyle(fontWeight: FontWeight.bold)),
 const SizedBox(height: 8),
 _buildTimeField(
 label: "Frühschicht Start",
 value: fruehStart,
 onTap: () async {
 final time = await _selectTime(context, fruehStart);
 if (time != null) setInnerState(() => fruehStart = time);
 },
 ),
 _buildTimeField(
 label: "Frühschicht Ende",
 value: fruehEnde,
 onTap: () async {
 final time = await _selectTime(context, fruehEnde);
 if (time != null) setInnerState(() => fruehEnde = time);
 },
 ),
 _buildTimeField(
 label: "Spätschicht Start",
 value: spaetStart,
 onTap: () async {
 final time = await _selectTime(context, spaetStart);
 if (time != null) setInnerState(() => spaetStart = time);
 },
 ),
 _buildTimeField(
 label: "Spätschicht Ende",
 value: spaetEnde,
 onTap: () async {
 final time = await _selectTime(context, spaetEnde);
 if (time != null) setInnerState(() => spaetEnde = time);
 },
 ),
 _buildTimeField(
 label: "Nachtschicht Start",
 value: nachtStart,
 onTap: () async {
 final time = await _selectTime(context, nachtStart);
 if (time != null) setInnerState(() => nachtStart = time);
 },
 ),
 _buildTimeField(
 label: "Nachtschicht Ende",
 value: nachtEnde,
 onTap: () async {
 final time = await _selectTime(context, nachtEnde);
 if (time != null) setInnerState(() => nachtEnde = time);
 },
 ),
 ],
 ],
 ),
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(dialogContext),
 child: const Text("Abbrechen"),
 ),
 FilledButton(
 child: const Text("Speichern"),
 onPressed: () async {
 final name = nameController.text.trim();
 if (name.isEmpty) {
 ScaffoldMessenger.of(dialogContext).showSnackBar(
 const SnackBar(content: Text("Bitte einen Betriebsnamen eingeben")),
 );
 return;
 }

 if (selectedArt["name"] == null || selectedArt["name"]!.isEmpty) {
 ScaffoldMessenger.of(dialogContext).showSnackBar(
 const SnackBar(content: Text("Bitte eine Betriebsart auswählen")),
 );
 return;
 }

 final neuerBetrieb = {
 "name": name,
 "kategorie": selectedKategorie,
 "betriebsart": selectedArt["name"]!,
 "risikoprofil": selectedArt["risiko"] ?? "standard",
 "schichtbetrieb": schichtbetrieb,
 if (schichtbetrieb) ...{
 "frueh_start": fruehStart.isNotEmpty ? fruehStart : null,
 "frueh_ende": fruehEnde.isNotEmpty ? fruehEnde : null,
 "spaet_start": spaetStart.isNotEmpty ? spaetStart : null,
 "spaet_ende": spaetEnde.isNotEmpty ? spaetEnde : null,
 "nacht_start": nachtStart.isNotEmpty ? nachtStart : null,
 "nacht_ende": nachtEnde.isNotEmpty ? nachtEnde : null,
 },
 };

 try {
 final added = await ref.read(betriebeProvider.notifier).addBetrieb(neuerBetrieb);
 if (added != null && dialogContext.mounted) {
 ref.read(selectedBetriebIdProvider.notifier).state = added['id'] as String?;
 Navigator.pop(dialogContext);
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text("Betrieb erfolgreich angelegt")),
 );
 }
 } catch (e) {
 if (dialogContext.mounted) {
 ScaffoldMessenger.of(dialogContext).showSnackBar(
 SnackBar(content: Text("Fehler beim Speichern: $e")),
 );
 }
 }
 },
 ),
 ],
 );
 },
 );
 },
 );
 }

 // ────────────────────────────────────────────────────────────────────────────
 // Ende der Klasse – schließende Klammer
 // ────────────────────────────────────────────────────────────────────────────
}