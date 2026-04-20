import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GeraetePage extends ConsumerStatefulWidget {
  final String betriebId;

  const GeraetePage({
    super.key,
    required this.betriebId,
  });

  @override
  ConsumerState<GeraetePage> createState() => _GeraetePageState();
}

class _GeraetePageState extends ConsumerState<GeraetePage> {
  List<Map<String, dynamic>> _geraete = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGeraete();
  }

  Future<void> _loadGeraete() async {
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client
          .from('geraete')
          .select()
          .eq('betrieb_id', widget.betriebId)
          .order('name');

      setState(() {
        _geraete = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddGeraetDialog() async {
    final nameController = TextEditingController();
    final intervallController = TextEditingController(text: "7");

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Neues Gerät hinzufügen"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Gerätename *"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: intervallController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Reinigungsintervall (Tage)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Bitte Gerätename eingeben")),
                );
                return;
              }

              try {
                await Supabase.instance.client.from('geraete').insert({
                  'betrieb_id': widget.betriebId,
                  'name': name,
                  'intervall_tage': int.tryParse(intervallController.text) ?? 7,
                });

                _loadGeraete(); // Liste neu laden

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gerät hinzugefügt")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Fehler: $e")),
                  );
                }
              }
            },
            child: const Text("Speichern"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geräte'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _geraete.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Noch keine Geräte vorhanden"),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _geraete.length,
                  itemBuilder: (context, index) {
                    final g = _geraete[index];
                    final intervall = g['intervall_tage'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.kitchen, color: Colors.orange, size: 40),
                        title: Text(g['name'] ?? "Unbenannt"),
                        subtitle: Text("Reinigungsintervall: $intervall Tage"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${g['name']} angeklickt')),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGeraetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}