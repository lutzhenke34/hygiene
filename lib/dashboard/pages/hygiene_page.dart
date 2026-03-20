import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_providers.dart';

class HygienePage extends ConsumerWidget {

  final String? betriebId;

  const HygienePage({
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

    final tasksAsync = ref.watch(
      hygieneTasksProvider(betriebId),
    );

    final logsAsync = ref.watch(
      hygieneLogsProvider(betriebId),
    );

    return tasksAsync.when(
      data: (tasks) => logsAsync.when(
        data: (logs) {

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [

                Row(
                  children: [

                    const Text(
                      "Hygiene Checkliste",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Hygienepunkt"),
                      onPressed: () =>
                          _addHygieneTask(context, ref, betriebId!),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {

                      final task = tasks[i];

                      final done = logs.any(
                        (l) =>
                            l["task_id"] == task["id"] &&
                            l["erledigt"] == true,
                      );

                      return Card(
                        child: CheckboxListTile(
                          value: done,
                          title: Text(task["name"]),
                          subtitle: Text(
                            "Rolle: ${task["rolle"] ?? "nicht definiert"}",
                          ),
                          onChanged: (v) {
                            _toggleHygieneTask(
                              ref,
                              task["id"],
                              betriebId!,
                              v ?? false,
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("$e")),
      ),
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("$e")),
    );
  }

  Future<void> _toggleHygieneTask(
    WidgetRef ref,
    String taskId,
    String betriebId,
    bool done,
  ) async {

    final today =
        DateTime.now().toIso8601String().substring(0, 10);

    await ref.read(supabaseProvider)
        .from("hygiene_logs")
        .upsert({
      "task_id": taskId,
      "betrieb_id": betriebId,
      "datum": today,
      "erledigt": done,
    });

    ref.invalidate(hygieneLogsProvider(betriebId));
  }

  Future<void> _addHygieneTask(
    BuildContext context,
    WidgetRef ref,
    String betriebId,
  ) async {

    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(

        title: const Text("Hygienepunkt"),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Aufgabe",
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

              await ref.read(supabaseProvider)
                  .from("hygiene_tasks")
                  .insert({
                "betrieb_id": betriebId,
                "name": controller.text,
              });

              ref.invalidate(
                hygieneTasksProvider(betriebId),
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