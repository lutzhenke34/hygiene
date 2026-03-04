import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/betriebe_controller.dart';

class BetriebePage extends ConsumerWidget {
  const BetriebePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final betriebeAsync = ref.watch(betriebeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Betriebe")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: betriebeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (betriebe) => ListView.builder(
          itemCount: betriebe.length,
          itemBuilder: (_, index) {
            final b = betriebe[index];
            return ListTile(
              title: Text(b.name),
              subtitle: Text(b.kategorie),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () =>
                    ref.read(betriebeControllerProvider.notifier)
                        .remove(b.id),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Neuer Betrieb"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(betriebeControllerProvider.notifier).addBetrieb(
                    name: controller.text,
                    kategorie: "Gastronomie",
                    betriebsart: "Restaurant",
                    risikoprofil: "Standard",
                    schichtbetrieb: false,
                  );
              Navigator.pop(context);
            },
            child: const Text("Speichern"),
          ),
        ],
      ),
    );
  }
}