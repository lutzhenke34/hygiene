import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_providers.dart';

class KuehlgeraetePage extends ConsumerWidget {

  final String? betriebId;

  const KuehlgeraetePage({
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

    final asyncData =
        ref.watch(kuehlgeraeteProvider(betriebId));

    return asyncData.when(
      data: (items) {

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Kühlgeräte",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          "Noch keine Kühlgeräte vorhanden",
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, i) {

                          final g = items[i];
                          final temp =
                              g['akt_temp'] ?? g['soll_temp'];

                          return Card(
                            margin:
                                const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(
                                Icons.ac_unit,
                                color: Colors.blue,
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
                                "Typ: ${g['typ']} • Soll: ${g['soll_temp']} °C",
                              ),
                              trailing: Chip(
                                label: Text("$temp °C"),
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
}