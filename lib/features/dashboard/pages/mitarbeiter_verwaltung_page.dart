import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../providers/mitarbeiter_provider.dart';
import '../../../providers/mitarbeiter_online_provider.dart';
import '../models/mitarbeiter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MitarbeiterVerwaltungPage extends ConsumerWidget {
  final String betriebId;

  const MitarbeiterVerwaltungPage({
    super.key,
    required this.betriebId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mitarbeiterAsync = ref.watch(mitarbeiterNotifierProvider(betriebId));
    final onlineIdsAsync = ref.watch(onlineMitarbeiterIdsProvider(betriebId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mitarbeiter verwalten'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: mitarbeiterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (mitarbeiter) {
          if (mitarbeiter.isEmpty) {
            return const Center(child: Text('Keine Mitarbeiter vorhanden'));
          }

          final onlineIds = onlineIdsAsync.value ?? <String>{};

          final sortedMitarbeiter = [...mitarbeiter]
            ..sort((a, b) {
              final aOnline = onlineIds.contains(a.id);
              final bOnline = onlineIds.contains(b.id);

              if (aOnline && !bOnline) return -1;
              if (!aOnline && bOnline) return 1;

              return a.nachname.toLowerCase().compareTo(
                    b.nachname.toLowerCase(),
                  );
            });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sortedMitarbeiter.length,
            itemBuilder: (context, index) {
              final m = sortedMitarbeiter[index];
              final isOnline = onlineIds.contains(m.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        backgroundColor: isOnline
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          color: isOnline
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? Colors.green
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text('${m.vorname} ${m.nachname}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: isOnline
                              ? Colors.green.shade700
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (m.kontakt != null) Text('Kontakt: ${m.kontakt}'),
                      if (m.rolle != null) Text('Rolle: ${m.rolle}'),
                      if (m.letzteSchulung != null)
                        Text(
                          'Schulung: ${m.letzteSchulung!.toString().split(' ')[0]}',
                        ),
                      if (m.hygieneausweisUrl != null)
                        const Text(
                          '✅ Hygieneausweis vorhanden',
                          style: TextStyle(color: Colors.green),
                        ),
                      Text(
                        'Hygieneaufgaben: ${m.canManageHygiene ? "Ja" : "Nein"}',
                      ),
                      Text(
                        'Aufgaben verwalten: ${m.canManageGeraete ? "Ja" : "Nein"}',
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
                          builder: (_) => AddMitarbeiterDialog(
                            betriebId: betriebId,
                            bestehenderMitarbeiter: m,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Mitarbeiter löschen?'),
                              content: Text(
                                'Möchten Sie "${m.vorname} ${m.nachname}" wirklich löschen?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Abbrechen'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Löschen',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await ref
                                  .read(
                                    mitarbeiterNotifierProvider(betriebId)
                                        .notifier,
                                  )
                                  .delete(m.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${m.vorname} ${m.nachname} wurde gelöscht',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Fehler beim Löschen: $e'),
                                  ),
                                );
                              }
                            }
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
          builder: (_) => AddMitarbeiterDialog(betriebId: betriebId),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('Neuer Mitarbeiter'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}

class AddMitarbeiterDialog extends ConsumerStatefulWidget {
  final String betriebId;
  final Mitarbeiter? bestehenderMitarbeiter;

  const AddMitarbeiterDialog({
    super.key,
    required this.betriebId,
    this.bestehenderMitarbeiter,
  });

  @override
  ConsumerState<AddMitarbeiterDialog> createState() =>
      _AddMitarbeiterDialogState();
}

class _AddMitarbeiterDialogState extends ConsumerState<AddMitarbeiterDialog> {
  final _formKey = GlobalKey<FormState>();

  final vornameController = TextEditingController();
  final nachnameController = TextEditingController();
  final kontaktController = TextEditingController();
  final pinController = TextEditingController();

  DateTime? letzteSchulung;
  PlatformFile? _selectedFile;
  bool _isSaving = false;

  List<Map<String, dynamic>> _rollen = [];
  String? _selectedRolle;

  bool _canManageHygiene = false;
  bool _canManageGeraete = false;
  bool _canViewAllProtokolle = true;

  @override
  void initState() {
    super.initState();
    final m = widget.bestehenderMitarbeiter;
    if (m != null) {
      vornameController.text = m.vorname;
      nachnameController.text = m.nachname;
      kontaktController.text = m.kontakt ?? '';
      pinController.text = m.pin;
      _selectedRolle = m.rolle;
      letzteSchulung = m.letzteSchulung;

      _canManageHygiene = m.canManageHygiene;
      _canManageGeraete = m.canManageGeraete;
      _canViewAllProtokolle = m.canViewAllProtokolle;
    } else {
      pinController.text = '1234';
    }
    _loadRollen();
  }

  Future<void> _loadRollen() async {
    try {
      final res =
          await Supabase.instance.client.from('rollen').select('name');
      setState(() => _rollen = List<Map<String, dynamic>>.from(res));
    } catch (e) {
      print('Fehler beim Laden der Rollen: $e');
    }
  }

  Future<void> _addNewRole() async {
    final controller = TextEditingController();
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Rolle erstellen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Rollenname'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(context, text);
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );

    if (newRole == null || newRole.isEmpty) return;

    try {
      await Supabase.instance.client
          .from('rollen')
          .insert({'name': newRole});
      await _loadRollen();
      setState(() => _selectedRolle = newRole);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Erstellen der Rolle')),
        );
      }
    }
  }

  Future<void> _pickHygieneFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _selectedFile = result.files.first);
      }
    } catch (e) {
      print('FilePicker Fehler: $e');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRolle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine Rolle auswählen')),
      );
      return;
    }
    if (pinController.text.trim().length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN muss 4-stellig sein')),
      );
      return;
    }

    setState(() => _isSaving = true);

    String? hygieneausweisUrl;

    try {
      if (_selectedFile != null) {
        final notifier = ref.read(
          mitarbeiterNotifierProvider(widget.betriebId).notifier,
        );

        Uint8List fileBytes;
        if (_selectedFile!.bytes != null) {
          fileBytes = _selectedFile!.bytes!;
        } else if (_selectedFile!.path != null) {
          fileBytes = await File(_selectedFile!.path!).readAsBytes();
        } else {
          throw Exception('Keine Dateidaten verfügbar');
        }

        final safeFileName =
            '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';

        hygieneausweisUrl = await notifier.uploadHygieneausweis(
          fileBytes,
          safeFileName,
        );
      }

      final mitarbeiter = Mitarbeiter(
        id: widget.bestehenderMitarbeiter?.id ?? '',
        betriebId: widget.betriebId,
        vorname: vornameController.text.trim(),
        nachname: nachnameController.text.trim(),
        kontakt: kontaktController.text.trim().isEmpty
            ? null
            : kontaktController.text.trim(),
        rolle: _selectedRolle!,
        pin: pinController.text.trim(),
        letzteSchulung: letzteSchulung,
        hygieneausweisUrl: hygieneausweisUrl,
        canManageHygiene: _canManageHygiene,
        canManageGeraete: _canManageGeraete,
        canManageSchichten: false,
        canViewAllProtokolle: _canViewAllProtokolle,
      );

      await ref
          .read(mitarbeiterNotifierProvider(widget.betriebId).notifier)
          .addOrUpdate(mitarbeiter);

      if (mounted) {
        ref.invalidate(mitarbeiterNotifierProvider(widget.betriebId));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mitarbeiter erfolgreich gespeichert')),
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
    vornameController.dispose();
    nachnameController.dispose();
    kontaktController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.bestehenderMitarbeiter == null
            ? 'Neuer Mitarbeiter'
            : 'Mitarbeiter bearbeiten',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: vornameController,
                decoration: const InputDecoration(labelText: 'Vorname *'),
                validator: (v) => v!.trim().isEmpty ? 'Pflichtfeld' : null,
              ),
              TextFormField(
                controller: nachnameController,
                decoration: const InputDecoration(labelText: 'Nachname *'),
                validator: (v) => v!.trim().isEmpty ? 'Pflichtfeld' : null,
              ),
              TextFormField(
                controller: kontaktController,
                decoration:
                    const InputDecoration(labelText: 'Kontakt (Telefon)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: pinController,
                decoration:
                    const InputDecoration(labelText: 'PIN (4-stellig) *'),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (v) => (v == null || v.trim().length != 4)
                    ? 'PIN muss genau 4-stellig sein'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRolle,
                      decoration: const InputDecoration(labelText: 'Rolle *'),
                      items: _rollen.map((r) {
                        final name = r['name'] as String;
                        return DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedRolle = value),
                      validator: (v) => v == null ? 'Bitte Rolle auswählen' : null,
                    ),
                  ),
                  IconButton(
                    onPressed: _addNewRole,
                    icon: const Icon(Icons.add_circle),
                    tooltip: 'Neue Rolle hinzufügen',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Berechtigungen',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: const Text('Darf Hygieneaufgaben verwalten'),
                subtitle: const Text('Hygieneaufgaben, Checklisten, etc.'),
                value: _canManageHygiene,
                onChanged: (value) =>
                    setState(() => _canManageHygiene = value),
              ),
              SwitchListTile(
                title: const Text('Darf Aufgaben verwalten'),
                subtitle: const Text('Allgemeine Aufgaben, Anweisungen, etc.'),
                value: _canManageGeraete,
                onChanged: (value) =>
                    setState(() => _canManageGeraete = value),
              ),
              SwitchListTile(
                title: const Text('Darf alle Protokolle einsehen'),
                value: _canViewAllProtokolle,
                onChanged: (value) =>
                    setState(() => _canViewAllProtokolle = value),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Letzte Hygiene-Schulung'),
                subtitle: Text(
                  letzteSchulung != null
                      ? letzteSchulung!.toString().split(' ')[0]
                      : 'Nicht gesetzt',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: letzteSchulung ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => letzteSchulung = date);
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickHygieneFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Hygieneausweis hochladen'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              if (_selectedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Ausgewählt: ${_selectedFile!.name}',
                    style: const TextStyle(color: Colors.green),
                  ),
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
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Speichern'),
        ),
      ],
    );
  }
}
