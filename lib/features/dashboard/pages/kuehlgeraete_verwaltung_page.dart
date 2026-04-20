import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/kuehlgeraet_provider.dart';
import '../models/kuehlgeraet.dart';

class KuehlgeraeteVerwaltungPage extends ConsumerWidget {
  final String betriebId;

  const KuehlgeraeteVerwaltungPage({super.key, required this.betriebId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geraeteAsync = ref.watch(kuehlgeraetNotifierProvider(betriebId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kühlgeräte verwalten'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: geraeteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (geraete) {
          if (geraete.isEmpty) {
            return const Center(
              child: Text(
                'Noch keine Kühlgeräte angelegt.\nDrücke auf + um eines hinzuzufügen.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: geraete.length,
            itemBuilder: (context, index) {
              final g = geraete[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.15),
                    radius: 28,
                    child: const Icon(Icons.kitchen, color: Colors.blue, size: 28),
                  ),
                  title: Text(
                    g.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (g.typ != null) Text('Typ: ${g.typ}'),
                      if (g.standort != null) Text('Standort: ${g.standort}'),
                      if (g.seriennummer != null) Text('Serien-Nr: ${g.seriennummer}'),
                      const SizedBox(height: 4),
                      Text(
                        'Solltemperatur: ${g.sollTemperatur?.toString() ?? "?"} °C',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                          fontSize: 15,
                        ),
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
                          builder: (_) => KuehlgeraetDialog(
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
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Löschen'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(kuehlgeraetNotifierProvider(betriebId).notifier).delete(g.id);
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
          builder: (_) => KuehlgeraetDialog(betriebId: betriebId),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Neues Kühlgerät'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}

// ====================== DIALOG (vereinfacht) ======================

class KuehlgeraetDialog extends ConsumerStatefulWidget {
  final String betriebId;
  final Kuehlgeraet? bestehendesGeraet;

  const KuehlgeraetDialog({
    super.key,
    required this.betriebId,
    this.bestehendesGeraet,
  });

  @override
  ConsumerState<KuehlgeraetDialog> createState() => _KuehlgeraetDialogState();
}

class _KuehlgeraetDialogState extends ConsumerState<KuehlgeraetDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _typController = TextEditingController();
  final _standortController = TextEditingController();
  final _seriennummerController = TextEditingController();
  final _sollTemperaturController = TextEditingController();
  final _notizenController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.bestehendesGeraet;
    if (g != null) {
      _nameController.text = g.name;
      _typController.text = g.typ ?? '';
      _standortController.text = g.standort ?? '';
      _seriennummerController.text = g.seriennummer ?? '';
      _sollTemperaturController.text = g.sollTemperatur?.toString() ?? '';
      _notizenController.text = g.notizen ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final geraet = Kuehlgeraet(
        id: widget.bestehendesGeraet?.id ?? '',
        betriebId: widget.betriebId,
        name: _nameController.text.trim(),
        typ: _typController.text.trim().isEmpty ? null : _typController.text.trim(),
        standort: _standortController.text.trim().isEmpty ? null : _standortController.text.trim(),
        seriennummer: _seriennummerController.text.trim().isEmpty ? null : _seriennummerController.text.trim(),
        sollTemperatur: double.tryParse(_sollTemperaturController.text.trim()),
        notizen: _notizenController.text.trim().isEmpty ? null : _notizenController.text.trim(),
      );

      await ref.read(kuehlgeraetNotifierProvider(widget.betriebId).notifier).addOrUpdate(geraet);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kühlgerät erfolgreich gespeichert')),
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
    _sollTemperaturController.dispose();
    _notizenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bestehendesGeraet == null ? 'Neues Kühlgerät' : 'Kühlgerät bearbeiten'),
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
                decoration: const InputDecoration(labelText: 'Typ (z.B. Kühlschrank, Tiefkühler, Kühlzelle)'),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _sollTemperaturController,
                decoration: const InputDecoration(labelText: 'Solltemperatur (°C) *'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Solltemperatur ist Pflicht';
                  if (double.tryParse(v.trim()) == null) return 'Bitte eine gültige Zahl eingeben';
                  return null;
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