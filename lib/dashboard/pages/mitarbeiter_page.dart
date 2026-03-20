import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/admin_providers.dart';

class MitarbeiterPage extends ConsumerWidget {
  final String? betriebId;

  const MitarbeiterPage({
    super.key,
    required this.betriebId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (betriebId == null) {
      return const Center(child: Text("Kein Betrieb ausgewählt"));
    }

    final mitarbeiterAsync = ref.watch(mitarbeiterProvider(betriebId));

    return mitarbeiterAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Fehler: $e")),
      data: (mitarbeiter) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Mitarbeiter",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Mitarbeiter hinzufügen"),
                    onPressed: () => _addMitarbeiter(context, ref, betriebId!),
                  )
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

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.person, color: Colors.indigo),
                              title: Text(
                                "${m["vorname"] ?? ""} ${m["nachname"] ?? ""}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Rolle: ${m["rolle"] ?? "-"}"),
                                  if (m["kontakt"] != null && m["kontakt"] != "")
                                    Text("Kontakt: ${m["kontakt"]}"),
                                  if (m["letzte_schulung"] != null)
                                    Text("Letzte Schulung: ${m["letzte_schulung"]}"),
                                  if (m["hygieneausweis"] != null && m["hygieneausweis"] != "")
                                    InkWell(
                                      child: const Text(
                                        "Hygieneausweis öffnen",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onTap: () async {
                                        final uri = Uri.parse(m["hygieneausweis"]);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri);
                                        }
                                      },
                                    ),
                                ],
                              ),
                              onTap: () =>
                                  _editMitarbeiter(context, ref, m, betriebId!),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await ref
                                      .read(supabaseProvider)
                                      .from("mitarbeiter")
                                      .delete()
                                      .eq("id", m["id"]);

                                  ref.invalidate(mitarbeiterProvider(betriebId));
                                },
                              ),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _addMitarbeiter(
      BuildContext context, WidgetRef ref, String betriebId) async {
    final vorname = TextEditingController();
    final nachname = TextEditingController();
    final rolle = TextEditingController();
    final telefon = TextEditingController();
    final email = TextEditingController();
    final letzteSchulung = TextEditingController();

    String? hygieneFileUrl;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mitarbeiter anlegen"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: vorname,
                decoration: const InputDecoration(labelText: "Vorname"),
              ),
              TextField(
                controller: nachname,
                decoration: const InputDecoration(labelText: "Nachname"),
              ),
              TextField(
                controller: rolle,
                decoration: const InputDecoration(labelText: "Rolle"),
              ),
              TextField(
                controller: telefon,
                decoration: const InputDecoration(labelText: "Telefon"),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: letzteSchulung,
                decoration: const InputDecoration(
                  labelText: "Letzte Hygieneschulung (YYYY-MM-DD)",
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Hygieneausweis hochladen"),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                    withData: true,
                  );

                  if (result == null) return;

                  final file = result.files.first;
                  print("Datei ausgewählt: ${file.name}");

                  // HIER später Supabase Upload einbauen
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          FilledButton(
            child: const Text("Speichern"),
            onPressed: () async {
              final data = {
                "betrieb_id": betriebId,
                "vorname": vorname.text,
                "nachname": nachname.text,
                "rolle": rolle.text,
                "kontakt": telefon.text.isNotEmpty
                    ? telefon.text
                    : email.text,
                "hygieneausweis": hygieneFileUrl,
              };

              if (letzteSchulung.text.isNotEmpty) {
                data["letzte_schulung"] = letzteSchulung.text;
              }

              await ref
                  .read(supabaseProvider)
                  .from("mitarbeiter")
                  .insert(data);

              ref.invalidate(mitarbeiterProvider(betriebId));

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _editMitarbeiter(
      BuildContext context, WidgetRef ref, Map m, String betriebId) async {
    final vorname = TextEditingController(text: m["vorname"]);
    final nachname = TextEditingController(text: m["nachname"]);
    final rolle = TextEditingController(text: m["rolle"]);
    final kontakt = TextEditingController(text: m["kontakt"]);
    final letzteSchulung =
        TextEditingController(text: m["letzte_schulung"]);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mitarbeiter bearbeiten"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: vorname,
                decoration: const InputDecoration(labelText: "Vorname"),
              ),
              TextField(
                controller: nachname,
                decoration: const InputDecoration(labelText: "Nachname"),
              ),
              TextField(
                controller: rolle,
                decoration: const InputDecoration(labelText: "Rolle"),
              ),
              TextField(
                controller: kontakt,
                decoration: const InputDecoration(labelText: "Kontakt"),
              ),
              TextField(
                controller: letzteSchulung,
                decoration:
                    const InputDecoration(labelText: "Letzte Schulung"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          FilledButton(
            child: const Text("Speichern"),
            onPressed: () async {
              await ref
                  .read(supabaseProvider)
                  .from("mitarbeiter")
                  .update({
                "vorname": vorname.text,
                "nachname": nachname.text,
                "rolle": rolle.text,
                "kontakt": kontakt.text,
                "letzte_schulung": letzteSchulung.text,
              }).eq("id", m["id"]);

              ref.invalidate(mitarbeiterProvider(betriebId));

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}