import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/aufgabe_provider.dart';
import '../../../providers/rollen_provider.dart';
import '../../../providers/schicht_provider.dart';
import '../models/aufgabe.dart';
import '../models/schicht.dart';

class AufgabenPage extends ConsumerWidget {
  final String betriebId;

  const AufgabenPage({super.key, required this.betriebId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aufgabenAsync = ref.watch(aufgabeNotifierProvider(betriebId));
    final schichtenAsync = ref.watch(schichtNotifierProvider(betriebId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aufgaben'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: aufgabenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (aufgaben) {
          if (aufgaben.isEmpty) {
            return const Center(
              child: Text('Noch keine Aufgaben angelegt.\nDrücke auf + um eine neue zu erstellen.'),
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
                    a.erledigt ? Icons.check_circle : Icons.assignment,
                    color: a.erledigt ? Colors.green : Colors.orange,
                    size: 32,
                  ),
                  title: Text(a.titel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (a.rolle != null) Text('Für: ${a.rolle}'),
                      if (a.faelligBis != null)
                        Text('Fällig bis: ${a.faelligBis!.toString().split(' ')[0]}'),
                      if (a.wiederholungsIntervallTage != null)
                        Text('Wiederholt alle ${a.wiederholungsIntervallTage} Tage'),
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
                          builder: (_) => AufgabeDialog(
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
                            await ref.read(aufgabeNotifierProvider(betriebId).notifier).delete(a.id);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(aufgabeNotifierProvider(betriebId).notifier).toggleErledigt(a.id);
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
          builder: (_) => AufgabeDialog(betriebId: betriebId),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Neue Aufgabe'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}

// ====================== DIALOG ======================

class AufgabeDialog extends ConsumerStatefulWidget {
  final String betriebId;
  final Aufgabe? bestehendeAufgabe;

  const AufgabeDialog({
    super.key,
    required this.betriebId,
    this.bestehendeAufgabe,
  });

  @override
  ConsumerState<AufgabeDialog> createState() => _AufgabeDialogState();
}

class _AufgabeDialogState extends ConsumerState<AufgabeDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titelController = TextEditingController();
  final _beschreibungController = TextEditingController();

  String? _selectedRolle;
  DateTime? _faelligBis;
  int? _wiederholungsIntervallTage;
  String? _selectedSchichtId;        // null = alle Schichten

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
      _titelController.text = a.titel;
      _beschreibungController.text = a.beschreibung ?? '';
      _selectedRolle = a.rolle;
      _faelligBis = a.faelligBis;
      _wiederholungsIntervallTage = a.wiederholungsIntervallTage;
      _selectedSchichtId = a.schichtId;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final aufgabe = Aufgabe(
        id: widget.bestehendeAufgabe?.id ?? '',
        betriebId: widget.betriebId,
        titel: _titelController.text.trim(),
        beschreibung: _beschreibungController.text.trim().isEmpty ? null : _beschreibungController.text.trim(),
        rolle: _selectedRolle,
        faelligBis: _faelligBis,
        wiederholungsIntervallTage: _wiederholungsIntervallTage,
        schichtId: _selectedSchichtId,
      );

      await ref.read(aufgabeNotifierProvider(widget.betriebId).notifier).addOrUpdate(aufgabe);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aufgabe erfolgreich gespeichert')),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schichtenAsync = ref.watch(schichtNotifierProvider(widget.betriebId));
    final rollenAsync = ref.watch(rollenProvider);

    return AlertDialog(
      title: Text(widget.bestehendeAufgabe == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titelController,
                decoration: const InputDecoration(labelText: 'Titel der Aufgabe *'),
                validator: (v) => v!.trim().isEmpty ? 'Titel ist Pflicht' : null,
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
                    decoration: const InputDecoration(labelText: 'Rolle / Team'),
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
                value: _wiederholungsIntervallTage,
                decoration: const InputDecoration(labelText: 'Wiederholung'),
                items: _intervalle.map((item) => DropdownMenuItem<int?>(
                  value: item['tage'] as int?,
                  child: Text(item['label'] as String),
                )).toList(),
                onChanged: (value) => setState(() => _wiederholungsIntervallTage = value),
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
                  if (date != null) setState(() => _faelligBis = date);
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _beschreibungController,
                decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
                maxLines: 4,
              ),
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
