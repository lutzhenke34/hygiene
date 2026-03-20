import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_providers.dart';

class GeraetePage extends ConsumerWidget {

  final String? betriebId;

  const GeraetePage({
    super.key,
    required this.betriebId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    if (betriebId == null) {
      return const Center(
        child: Text("Kein Betrieb ausgewählt"),
      );
    }

    final geraeteAsync =
        ref.watch(geraeteProvider(betriebId));

    return geraeteAsync.when(
      data: (items) {

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  const Text(
                    "Geräte",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Gerät hinzufügen"),
                    onPressed: () =>
                        _showAddGeraetDialog(context, ref, betriebId!),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          "Noch keine Geräte vorhanden",
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, i) {

                          final g = items[i];
                          final intervall =
                              g['intervall_tage'] ?? 0;

                          return Card(
                            margin:
                                const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(
                                Icons.build,
                                color: Colors.orange,
                                size: 36,
                              ),
                              title: Text(
                                g['name'] ?? "Unbenannt",
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "Reinigungsintervall: $intervall Tage",
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },

      loading: () =>
          const Center(child: CircularProgressIndicator()),

      error: (e, _) => Center(child: Text("Fehler: $e")),
    );
  }

  Future<void> _showAddGeraetDialog(
    BuildContext context,
    WidgetRef ref,
    String betriebId,
  ) async {

    final nameController = TextEditingController();
    final intervallController =
        TextEditingController(text: "7");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(

        title: const Text("Gerät hinzufügen"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Gerätename",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: intervallController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Reinigungsintervall (Tage)",
              ),
            ),
          ],
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),

          FilledButton(
            child: const Text("Speichern"),
            onPressed: () async {

              await ref.read(supabaseProvider)
                  .from("geraete")
                  .insert({
                "betrieb_id": betriebId,
                "name": nameController.text,
                "intervall_tage":
                    int.tryParse(intervallController.text) ?? 7,
              });

              ref.invalidate(
                geraeteProvider(betriebId),
              );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }
}