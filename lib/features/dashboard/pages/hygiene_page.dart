import 'package:flutter/material.dart';

class HygienePage extends StatefulWidget {
  final String? betriebId;

  const HygienePage({
    super.key,
    required this.betriebId,
  });

  @override
  State<HygienePage> createState() => _HygienePageState();
}

class _HygienePageState extends State<HygienePage> {

  final List<Map<String, dynamic>> tasks = [];
  final Map<String, bool> erledigt = {};

  @override
  Widget build(BuildContext context) {

    if (widget.betriebId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Hygiene")),
        body: const Center(child: Text("Kein Betrieb ausgewählt")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hygiene Checkliste"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text("Punkt"),
        backgroundColor: Colors.green,
      ),

      body: tasks.isEmpty
          ? const Center(child: Text("Keine Hygienepunkte"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, i) {

                final task = tasks[i];
                final done = erledigt[task["id"]] ?? false;

                return Card(
                  child: CheckboxListTile(
                    value: done,
                    title: Text(task["name"]),
                    subtitle: Text(
                      done ? "Erledigt" : "Offen",
                    ),
                    onChanged: (v) {
                      setState(() {
                        erledigt[task["id"]] = v ?? false;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  void _addTask() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hygienepunkt"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Aufgabe"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                tasks.add({
                  "id": DateTime.now().toString(),
                  "name": controller.text,
                });
              });

              Navigator.pop(context);
            },
            child: const Text("Speichern"),
          )
        ],
      ),
    );
  }
}