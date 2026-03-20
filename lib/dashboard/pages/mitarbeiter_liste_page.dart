import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_providers.dart';

class MitarbeiterListePage extends ConsumerWidget {
  final String betriebId;

  const MitarbeiterListePage({super.key, required this.betriebId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anwesenheitAsync =
        ref.watch(anwesenheitProvider(betriebId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mitarbeiter vor Ort"),
      ),
      body: anwesenheitAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("$e")),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text("Niemand anwesend"),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final a = list[index];

              final vorname =
                  a['profiles']?['vorname'] ?? '';
              final nachname =
                  a['profiles']?['nachname'] ?? '';

              final name =
                  "$vorname $nachname".trim().isEmpty
                      ? 'Unbekannt'
                      : "$vorname $nachname";

              return ListTile(
                leading: const Icon(Icons.person),

                /// ✅ Name richtig gesetzt
                title: Text(name),

                /// ✅ Zusatzinfos
                subtitle: Text(
                  "Seit: ${a['login_time']}\n${a['profiles']?['rolle'] ?? ''}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}