import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_providers.dart';
import '../../widgets/stat_card.dart';

class OverviewPage extends ConsumerWidget {
  final Map<String, dynamic> betrieb;
  final String? betriebId;

  const OverviewPage({
    super.key,
    required this.betrieb,
    required this.betriebId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (betriebId == null) {
      return const Center(
        child: Text("Kein Betrieb ausgewählt"),
      );
    }

    final mitarbeiterAsync =
        ref.watch(mitarbeiterProvider(betriebId));

    final hygieneTasksAsync =
        ref.watch(hygieneTasksProvider(betriebId));

    final hygieneLogsAsync =
        ref.watch(hygieneLogsProvider(betriebId));

    final anwesenheitAsync =
        ref.watch(anwesenheitProvider(betriebId));

    return mitarbeiterAsync.when(
      data: (mitarbeiter) {
        final tasks = hygieneTasksAsync.value ?? [];
        final logs = hygieneLogsAsync.value ?? [];
        final anwesenheit = anwesenheitAsync.value ?? [];

        /// offene Hygiene
        int offeneHygiene = tasks.where((task) {
          final erledigt = logs.any((l) =>
              l["task_id"] == task["id"] &&
              l["erledigt"] == true);
          return !erledigt;
        }).length;

        /// offene Aufgaben
        int offeneAufgaben = tasks.length - logs.length;
        if (offeneAufgaben < 0) offeneAufgaben = 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Betriebsname
              Text(
                betrieb['name'] ?? "",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              /// 🔥 Kacheln
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  /// 👥 Mitarbeiter vor Ort (klickbar)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MitarbeiterLivePage(
                            betriebId: betriebId!,
                          ),
                        ),
                      );
                    },
                    child: StatCard(
                      title: "Mitarbeiter vor Ort",
                      value: anwesenheit.length.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),

                  /// 🧼 Hygiene
                  StatCard(
                    title: "Offene Hygiene",
                    value: offeneHygiene.toString(),
                    icon: Icons.cleaning_services,
                    color: Colors.red,
                  ),

                  /// 📋 Aufgaben
                  StatCard(
                    title: "Offene Aufgaben",
                    value: offeneAufgaben.toString(),
                    icon: Icons.assignment,
                    color: Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// 🔥 HACCP Button
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/hygiene',
                    arguments: betriebId,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 16),
                      Text(
                        "HACCP Protokolle öffnen",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },

      loading: () =>
          const Center(child: CircularProgressIndicator()),

      error: (e, _) => Center(child: Text("$e")),
    );
  }
}

/// 🔥 Live Mitarbeiterliste
class MitarbeiterLivePage extends ConsumerWidget {
  final String betriebId;

  const MitarbeiterLivePage({
    super.key,
    required this.betriebId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anwesenheitAsync =
        ref.watch(anwesenheitProvider(betriebId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Anwesende Mitarbeiter"),
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

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  a['profiles']?['telefonnummer'] ??
                      'Unbekannt',
                ),
                subtitle: Text(
                  "Seit: ${a['login_time']}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}