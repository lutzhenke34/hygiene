import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/hygiene_aufgabe_provider.dart';
import '../../../providers/kuehlgeraet_provider.dart';
import '../../../providers/geraet_provider.dart';
import '../../../providers/rollen_provider.dart';
import '../../../providers/schicht_provider.dart';
import '../models/hygiene_aufgabe.dart';
import '../models/kuehlgeraet.dart';
import '../models/geraet.dart';
import '../models/schicht.dart';

class HygieneAufgabenPage extends ConsumerWidget {
  final String betriebId;

  const HygieneAufgabenPage({super.key, required this.betriebId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aufgabenAsync = ref.watch(hygieneAufgabeNotifierProvider(betriebId));
    final schichtenAsync = ref.watch(schichtNotifierProvider(betriebId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hygieneaufgaben'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: aufgabenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (aufgaben) {
          if (aufgaben.isEmpty) {
            return const Center(
              child: Text('Noch keine Hygieneaufgaben angelegt.\nDrücke auf + um eine neue zu erstellen.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: aufgaben.length,
            itemBuilder: (context, index) {
              final a = aufgaben[index];

              final schichtName = schichtenAsync.value
                  ?.firstWhere((s) => s.id == a.schichtId, orElse: () => Schicht(
                        id: '',
                        betriebId: '',
                        name: 'Alle Schichten',
                        startZeit: DateTime.now(),
                        endeZeit: DateTime.now(),
                      ))
                  .name;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    a.erledigt ? Icons.check_circle : Icons.task_alt,
                    color: a.erledigt ? Colors.green : Colors.orange,
                    size: 32,
                  ),
                  title: Text(a.titel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Typ: ${a.typ.name.toUpperCase()}'),
                      if (a.rolle != null) Text('Rolle: ${a.rolle}'),
                      if (a.faelligBis != null)
                        Text('Fällig bis: ${a.faelligBis!.toString().split(' ')[0]}'),
                      if (a.protokollName != null)
                        Text('Protokoll: ${a.protokollName}', style: const TextStyle(color: Colors.green)),
                      if (a.schichtId != null)
                        Text('Schicht: $schichtName', style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => HygieneAufgabeDialog(
                            betriebId: betriebId,
                            bestehendeAufgabe: a,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Aufgabe löschen?'),
                              content: Text('Möchten Sie "${a.titel}" wirklich löschen?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Löschen'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(hygieneAufgabeNotifierProvider(betriebId).notifier).delete(a.id);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(hygieneAufgabeNotifierProvider(betriebId).notifier).toggleErledigt(a.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => HygieneAufgabeDialog(betriebId: betriebId),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Neue Aufgabe'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}

// ====================== DIALOG ======================

class HygieneAufgabeDialog extends ConsumerStatefulWidget {
  final String betriebId;
  final HygieneAufgabe? bestehendeAufgabe;

  const HygieneAufgabeDialog({
    super.key,
    required this.betriebId,
    this.bestehendeAufgabe,
  });

  @override
  ConsumerState<HygieneAufgabeDialog> createState() => _HygieneAufgabeDialogState();
}

class _HygieneAufgabeDialogState extends ConsumerState<HygieneAufgabeDialog> {
  final _formKey = GlobalKey<FormState>();

  late HygieneAufgabeTyp _selectedTyp;
  final _titelController = TextEditingController();
  final _beschreibungController = TextEditingController();

  String? _selectedKuehlgeraetId;
  String? _selectedGeraetId;
  String? _selectedRolle;
  DateTime? _faelligBis;
  int? _wiederholungsIntervall;

  // Hygieneprotokoll
  bool _istProtokoll = false;
  String? _selectedExistingProtokoll;
  final _neuerProtokollNameController = TextEditingController();

  // Schicht-Zuordnung
  String? _selectedSchichtId;

  bool _isSaving = false;

  final List<Map<String, dynamic>> _intervalle = [
    {'tage': null, 'label': 'Einmalig'},
    {'tage': 1, 'label': 'Täglich'},
    {'tage': 7, 'label': 'Wöchentlich'},
    {'tage': 14, 'label': 'Alle 14 Tage'},
    {'tage': 30, 'label': 'Monatlich'},
    {'tage': 90, 'label': 'Alle 3 Monate'},
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.bestehendeAufgabe;
    if (a != null) {
      _selectedTyp = a.typ;
      _titelController.text = a.titel;
      _beschreibungController.text = a.beschreibung ?? '';
      _selectedKuehlgeraetId = a.kuehlgeraetId;
      _selectedGeraetId = a.geraetId;
      _selectedRolle = a.rolle;
      _faelligBis = a.faelligBis;
      _wiederholungsIntervall = a.wiederholungsIntervall;
      _istProtokoll = a.protokollName != null && a.protokollName!.isNotEmpty;
      _selectedExistingProtokoll = a.protokollName;
      _selectedSchichtId = a.schichtId;
    } else {
      _selectedTyp = HygieneAufgabeTyp.individuell;
    }
  }

  String _generateTitel() {
    if (_selectedTyp == HygieneAufgabeTyp.individuell) {
      return _titelController.text.trim();
    } else if (_selectedTyp == HygieneAufgabeTyp.temperaturprotokoll) {
      return 'Temperaturprotokoll';
    } else if (_selectedTyp == HygieneAufgabeTyp.geraete) {
      return 'Geräte-Reinigung';
    }
    return _titelController.text.trim();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final titel = _generateTitel();

      final protokollName = _istProtokoll 
          ? (_selectedExistingProtokoll ?? _neuerProtokollNameController.text.trim())
          : null;

      final aufgabe = HygieneAufgabe(
        id: widget.bestehendeAufgabe?.id ?? '',
        betriebId: widget.betriebId,
        typ: _selectedTyp,
        titel: titel.isEmpty ? 'Unbenannte Aufgabe' : titel,
        beschreibung: _beschreibungController.text.trim().isEmpty ? null : _beschreibungController.text.trim(),
        kuehlgeraetId: _selectedTyp == HygieneAufgabeTyp.temperaturprotokoll ? _selectedKuehlgeraetId : null,
        geraetId: _selectedTyp == HygieneAufgabeTyp.geraete ? _selectedGeraetId : null,
        rolle: _selectedRolle,
        faelligBis: _faelligBis,
        wiederholungsIntervall: _wiederholungsIntervall,
        protokollName: protokollName?.isNotEmpty == true ? protokollName : null,
        schichtId: _selectedSchichtId,
      );

      await ref.read(hygieneAufgabeNotifierProvider(widget.betriebId).notifier).addOrUpdate(aufgabe);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hygieneaufgabe gespeichert')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titelController.dispose();
    _beschreibungController.dispose();
    _neuerProtokollNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kuehlgeraeteAsync = ref.watch(kuehlgeraetNotifierProvider(widget.betriebId));
    final geraeteAsync = ref.watch(geraetNotifierProvider(widget.betriebId));
    final rollenAsync = ref.watch(rollenProvider);
    final schichtenAsync = ref.watch(schichtNotifierProvider(widget.betriebId));
    final alleAufgabenAsync = ref.watch(hygieneAufgabeNotifierProvider(widget.betriebId));

    final existingProtokolle = alleAufgabenAsync.value
            ?.where((a) => a.protokollName != null && a.protokollName!.isNotEmpty)
            .map((a) => a.protokollName!)
            .toSet()
            .toList() ??
        [];

    return AlertDialog(
      title: Text(widget.bestehendeAufgabe == null ? 'Neue Hygieneaufgabe' : 'Hygieneaufgabe bearbeiten'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<HygieneAufgabeTyp>(
                value: _selectedTyp,
                decoration: const InputDecoration(labelText: 'Art der Aufgabe'),
                items: const [
                  DropdownMenuItem(value: HygieneAufgabeTyp.individuell, child: Text('Individuell (Freitext)')),
                  DropdownMenuItem(value: HygieneAufgabeTyp.temperaturprotokoll, child: Text('Temperaturprotokoll')),
                  DropdownMenuItem(value: HygieneAufgabeTyp.geraete, child: Text('Geräte-Reinigung')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTyp = value!;
                    if (value == HygieneAufgabeTyp.temperaturprotokoll) {
                      _wiederholungsIntervall = 1; // Automatisch täglich
                    }
                    if (value != HygieneAufgabeTyp.individuell) {
                      _titelController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              if (_selectedTyp == HygieneAufgabeTyp.individuell)
                TextFormField(
                  controller: _titelController,
                  decoration: const InputDecoration(labelText: 'Titel der Aufgabe *'),
                  validator: (v) => v!.trim().isEmpty ? 'Titel ist Pflicht' : null,
                ),

              const SizedBox(height: 16),

              if (_selectedTyp == HygieneAufgabeTyp.temperaturprotokoll)
                kuehlgeraeteAsync.when(
                  data: (kuehlgeraete) => DropdownButtonFormField<String>(
                    value: _selectedKuehlgeraetId,
                    decoration: const InputDecoration(labelText: 'Kühlgerät auswählen'),
                    items: kuehlgeraete.map((g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(g.name),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedKuehlgeraetId = val),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, st) => const Text('Fehler beim Laden der Kühlgeräte'),
                ),

              if (_selectedTyp == HygieneAufgabeTyp.geraete)
                geraeteAsync.when(
                  data: (geraete) => DropdownButtonFormField<String>(
                    value: _selectedGeraetId,
                    decoration: const InputDecoration(labelText: 'Gerät auswählen'),
                    items: geraete.map((g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(g.name),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedGeraetId = val),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, st) => const Text('Fehler beim Laden der Geräte'),
                ),

              const SizedBox(height: 16),

              // Schicht-Auswahl
              schichtenAsync.when(
                data: (schichten) => DropdownButtonFormField<String?>(
                  value: _selectedSchichtId,
                  decoration: const InputDecoration(labelText: 'Schicht (optional)'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Alle Schichten'),
                    ),
                    ...schichten.map((s) => DropdownMenuItem<String?>(
                      value: s.id,
                      child: Text(s.name),
                    )),
                  ],
                  onChanged: (val) => setState(() => _selectedSchichtId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => const Text('Fehler beim Laden der Schichten'),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<int?>(
                value: _wiederholungsIntervall,
                decoration: const InputDecoration(labelText: 'Wiederholung'),
                items: _intervalle.map((item) => DropdownMenuItem<int?>(
                  value: item['tage'] as int?,
                  child: Text(item['label'] as String),
                )).toList(),
                onChanged: (value) => setState(() => _wiederholungsIntervall = value),
              ),

              const SizedBox(height: 16),

              rollenAsync.when(
                data: (rollen) {
                  final rollenItems = <String>{
                    ...rollen,
                    if (_selectedRolle != null && _selectedRolle!.trim().isNotEmpty)
                      _selectedRolle!,
                    'Alle',
                  }.toList()
                    ..sort((a, b) {
                      if (a == 'Alle') return 1;
                      if (b == 'Alle') return -1;
                      return a.toLowerCase().compareTo(b.toLowerCase());
                    });

                  return DropdownButtonFormField<String>(
                    value: _selectedRolle,
                    decoration: const InputDecoration(labelText: 'Rolle / Team *'),
                    validator: (v) => v == null ? 'Rolle ist Pflicht' : null,
                    items: rollenItems
                        .map(
                          (rolle) =>
                              DropdownMenuItem(value: rolle, child: Text(rolle)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedRolle = val),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Fehler beim Laden der Rollen: $e'),
              ),

              const SizedBox(height: 16),

              ListTile(
                title: const Text('Fällig bis *'),
                subtitle: Text(_faelligBis != null
                    ? _faelligBis!.toString().split(' ')[0]
                    : 'Bitte auswählen'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _faelligBis ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _faelligBis = date);
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _beschreibungController,
                decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Hygieneprotokoll
              const Divider(),
              SwitchListTile(
                title: const Text('Als Hygieneprotokoll führen'),
                subtitle: const Text('Wird in HACCP-Protokollen angezeigt'),
                value: _istProtokoll,
                onChanged: (val) => setState(() => _istProtokoll = val),
              ),

              if (_istProtokoll) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: _selectedExistingProtokoll,
                  decoration: const InputDecoration(labelText: 'Protokoll auswählen'),
                  items: [
                    ...existingProtokolle.map((name) => DropdownMenuItem<String?>(
                          value: name,
                          child: Text(name),
                        )),
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Neues Protokoll anlegen...'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedExistingProtokoll = value);
                  },
                ),
                if (_selectedExistingProtokoll == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextFormField(
                      controller: _neuerProtokollNameController,
                      decoration: const InputDecoration(
                        labelText: 'Neuer Protokollname',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Speichern'),
        ),
      ],
    );
  }
}
