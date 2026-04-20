import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/schicht_provider.dart';
import '../../../providers/ruhetage_provider.dart';
import '../models/schicht.dart';

class SchichtenVerwaltungPage extends ConsumerWidget {
  final String betriebId;

  const SchichtenVerwaltungPage({super.key, required this.betriebId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schichtenAsync = ref.watch(schichtNotifierProvider(betriebId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schichten und Ruhetage verwalten'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Ruhetage Bereich
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wöchentliche Ruhetage',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                RuhetageAuswahl(betriebId: betriebId),
              ],
            ),
          ),

          // Schichten Liste
          Expanded(
            child: schichtenAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Fehler: $e')),
              data: (schichten) {
                if (schichten.isEmpty) {
                  return const Center(
                    child: Text(
                      'Noch keine Schichten angelegt.\nDrücke auf + um eine neue Schicht zu erstellen.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: schichten.length,
                  itemBuilder: (context, index) {
                    final s = schichten[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.access_time, color: Colors.blue, size: 32),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${_formatTime(s.startZeit)} - ${_formatTime(s.endeZeit)}'),
                            if (s.beschreibung != null && s.beschreibung!.isNotEmpty)
                              Text(s.beschreibung!),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showSchichtDialog(context, ref, betriebId, s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSchicht(context, ref, betriebId, s.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSchichtDialog(context, ref, betriebId),
        icon: const Icon(Icons.add),
        label: const Text('Neue Schicht'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showSchichtDialog(BuildContext context, WidgetRef ref, String betriebId, [Schicht? bestehende]) {
    showDialog(
      context: context,
      builder: (_) => SchichtDialog(
        betriebId: betriebId,
        bestehendeSchicht: bestehende,
      ),
    );
  }

  void _deleteSchicht(BuildContext context, WidgetRef ref, String betriebId, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schicht löschen?'),
        content: const Text('Möchten Sie diese Schicht wirklich löschen?'),
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
      await ref.read(schichtNotifierProvider(betriebId).notifier).delete(id);
    }
  }
}

// ====================== RUHETAGE AUSWAHL ======================

// ====================== RUHETAGE AUSWAHL (optional – für durchgehend geöffnete Betriebe) ======================

class RuhetageAuswahl extends ConsumerStatefulWidget {
  final String betriebId;

  const RuhetageAuswahl({super.key, required this.betriebId});

  @override
  ConsumerState<RuhetageAuswahl> createState() => _RuhetageAuswahlState();
}

class _RuhetageAuswahlState extends ConsumerState<RuhetageAuswahl> {
  final List<String> _tage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final ruhetageAsync = ref.watch(ruhetageNotifierProvider(widget.betriebId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ruhetageAsync.when(
          loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Fehler: $e'),
          data: (selectedDays) {
            final hasNoRuhetage = selectedDays.isEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(7, (index) {
                    final isSelected = selectedDays.contains(index);

                    return FilterChip(
                      label: Text(
                        _tage[index],
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.green.shade800 : null,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.green.shade100,
                      checkmarkColor: Colors.green.shade700,
                      backgroundColor: Colors.white,
                      onSelected: (bool selected) async {
                        final notifier = ref.read(ruhetageNotifierProvider(widget.betriebId).notifier);

                        List<int> newList = List.from(selectedDays);

                        if (selected) {
                          newList.add(index);
                        } else {
                          newList.remove(index);
                        }

                        await notifier.saveRuhetage(newList);
                      },
                    );
                  }),
                ),

                const SizedBox(height: 12),

                // Info-Text für durchgehend geöffnete Betriebe
                if (hasNoRuhetage)
                  const Text(
                    'Keine Ruhetage ausgewählt = Betrieb ist durchgehend geöffnet',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ====================== SCHICHT DIALOG ======================

class SchichtDialog extends ConsumerStatefulWidget {
  final String betriebId;
  final Schicht? bestehendeSchicht;

  const SchichtDialog({
    super.key,
    required this.betriebId,
    this.bestehendeSchicht,
  });

  @override
  ConsumerState<SchichtDialog> createState() => _SchichtDialogState();
}

class _SchichtDialogState extends ConsumerState<SchichtDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _beschreibungController = TextEditingController();

  TimeOfDay _startTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 14, minute: 0);
  bool _aktiv = true;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.bestehendeSchicht != null) {
      final s = widget.bestehendeSchicht!;
      _nameController.text = s.name;
      _beschreibungController.text = s.beschreibung ?? '';
      _startTime = TimeOfDay.fromDateTime(s.startZeit);
      _endTime = TimeOfDay.fromDateTime(s.endeZeit);
      _aktiv = s.aktiv;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final startDateTime = DateTime(2024, 1, 1, _startTime.hour, _startTime.minute);
      final endDateTime = DateTime(2024, 1, 1, _endTime.hour, _endTime.minute);

      final schicht = Schicht(
        id: widget.bestehendeSchicht?.id ?? '',
        betriebId: widget.betriebId,
        name: _nameController.text.trim(),
        startZeit: startDateTime,
        endeZeit: endDateTime,
        beschreibung: _beschreibungController.text.trim().isEmpty ? null : _beschreibungController.text.trim(),
        aktiv: _aktiv,
      );

      await ref.read(schichtNotifierProvider(widget.betriebId).notifier).addOrUpdate(schicht);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schicht gespeichert')),
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
    _nameController.dispose();
    _beschreibungController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bestehendeSchicht == null ? 'Neue Schicht' : 'Schicht bearbeiten'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name der Schicht *'),
                validator: (v) => v!.trim().isEmpty ? 'Name ist Pflicht' : null,
              ),
              const SizedBox(height: 16),

              ListTile(
                title: const Text('Startzeit'),
                subtitle: Text(_startTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _startTime);
                  if (time != null) setState(() => _startTime = time);
                },
              ),

              ListTile(
                title: const Text('Endzeit'),
                subtitle: Text(_endTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _endTime);
                  if (time != null) setState(() => _endTime = time);
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _beschreibungController,
                decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
                maxLines: 2,
              ),

              SwitchListTile(
                title: const Text('Aktiv'),
                value: _aktiv,
                onChanged: (v) => setState(() => _aktiv = v),
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