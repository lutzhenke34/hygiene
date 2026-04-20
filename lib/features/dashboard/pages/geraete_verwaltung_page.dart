import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/geraet_provider.dart';        // wird gleich erstellt
import '../models/geraet.dart';

class GeraeteVerwaltungPage extends ConsumerWidget {
  final String betriebId;

  const GeraeteVerwaltungPage({super.key, required this.betriebId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geraeteAsync = ref.watch(geraetNotifierProvider(betriebId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geräte verwalten'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: geraeteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (geraete) {
          if (geraete.isEmpty) {
            return const Center(
              child: Text('Noch keine Geräte angelegt.\nDrücke auf + um eines hinzuzufügen.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: geraete.length,
            itemBuilder: (context, index) {
              final g = geraete[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.15),
                    child: const Icon(Icons.build, color: Colors.teal),
                  ),
                  title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (g.typ != null) Text('Typ: ${g.typ}'),
                      if (g.standort != null) Text('Standort: ${g.standort}'),
                      if (g.seriennummer != null) Text('Serien-Nr: ${g.seriennummer}'),
                      if (g.reinigungsintervallTage != null)
                        Text(
                          'Reinigungsintervall: alle ${g.reinigungsintervallTage} Tage',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => GeraetDialog(
                            betriebId: betriebId,
                            bestehendesGeraet: g,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Gerät löschen?'),
                              content: Text('Möchten Sie "${g.name}" wirklich löschen?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Löschen', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(geraetNotifierProvider(betriebId).notifier).delete(g.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => GeraetDialog(betriebId: betriebId),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Neues Gerät'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}

// ====================== DIALOG ======================

class GeraetDialog extends ConsumerStatefulWidget {
  final String betriebId;
  final Geraet? bestehendesGeraet;

  const GeraetDialog({
    super.key,
    required this.betriebId,
    this.bestehendesGeraet,
  });

  @override
  ConsumerState<GeraetDialog> createState() => _GeraetDialogState();
}

class _GeraetDialogState extends ConsumerState<GeraetDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _typController = TextEditingController();
  final _standortController = TextEditingController();
  final _seriennummerController = TextEditingController();
  final _notizenController = TextEditingController();

  int? _reinigungsintervallTage;

  bool _isSaving = false;

  final List<Map<String, dynamic>> _intervalle = [
    {'tage': 1, 'label': 'Täglich'},
    {'tage': 7, 'label': 'Wöchentlich'},
    {'tage': 14, 'label': 'Alle 14 Tage'},
    {'tage': 30, 'label': 'Monatlich'},
    {'tage': 90, 'label': 'Alle 3 Monate'},
    {'tage': null, 'label': 'Anderes Intervall'},
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.bestehendesGeraet;
    if (g != null) {
      _nameController.text = g.name;
      _typController.text = g.typ ?? '';
      _standortController.text = g.standort ?? '';
      _seriennummerController.text = g.seriennummer ?? '';
      _notizenController.text = g.notizen ?? '';
      _reinigungsintervallTage = g.reinigungsintervallTage;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final geraet = Geraet(
        id: widget.bestehendesGeraet?.id ?? '',
        betriebId: widget.betriebId,
        name: _nameController.text.trim(),
        typ: _typController.text.trim().isEmpty ? null : _typController.text.trim(),
        standort: _standortController.text.trim().isEmpty ? null : _standortController.text.trim(),
        seriennummer: _seriennummerController.text.trim().isEmpty ? null : _seriennummerController.text.trim(),
        reinigungsintervallTage: _reinigungsintervallTage,
        notizen: _notizenController.text.trim().isEmpty ? null : _notizenController.text.trim(),
      );

      await ref.read(geraetNotifierProvider(widget.betriebId).notifier).addOrUpdate(geraet);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gerät erfolgreich gespeichert')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typController.dispose();
    _standortController.dispose();
    _seriennummerController.dispose();
    _notizenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bestehendesGeraet == null ? 'Neues Gerät' : 'Gerät bearbeiten'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Gerätename *'),
                validator: (v) => v!.trim().isEmpty ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typController,
                decoration: const InputDecoration(labelText: 'Typ (z.B. Geschirrspüler, Ofen, Mixer)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _standortController,
                decoration: const InputDecoration(labelText: 'Standort / Raum'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _seriennummerController,
                decoration: const InputDecoration(labelText: 'Seriennummer / Inventarnummer'),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int?>(
                value: _reinigungsintervallTage,
                decoration: const InputDecoration(labelText: 'Reinigungsintervall'),
                items: _intervalle.map((item) {
                  return DropdownMenuItem<int?>(
                    value: item['tage'] as int?,
                    child: Text(item['label'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _reinigungsintervallTage = value);
                },
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _notizenController,
                decoration: const InputDecoration(labelText: 'Notizen'),
                maxLines: 3,
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