import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/supabase_client.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/admin_dashboard_page.dart';
import '../dashboard/employee_home_page.dart';
import 'betrieb_anlegen_page.dart'; // ← Anlegen-Screen
import 'betrieb_bearbeiten_page.dart'; // ← Bearbeiten-Screen

final selectedBetriebProvider = StateProvider<String?>((ref) => null);

class BetriebAuswahlPage extends ConsumerStatefulWidget {
  const BetriebAuswahlPage({super.key});

  @override
  ConsumerState<BetriebAuswahlPage> createState() => _BetriebAuswahlPageState();
}

class _BetriebAuswahlPageState extends ConsumerState<BetriebAuswahlPage> {
  List<Map<String, dynamic>> _betriebe = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBetriebe();
  }

  Future<void> _loadBetriebe() async {
    final user = ref.read(authProvider);

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await supabase
          .from('user_betrieb')
          .select('''
            betrieb_id,
            rolle,
            is_favorit,
            last_used,
            betriebe!inner (id, name, adresse, ort)
          ''')
          .eq('user_id', user.id)
          .order('is_favorit', ascending: false)
          .order('last_used', ascending: false, nullsFirst: true);

      setState(() {
        _betriebe = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });

      if (_betriebe.length == 1) {
        await _selectBetrieb(_betriebe.first);
      }
    } catch (e) {
      print('Fehler beim Laden der Betriebe: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden: $e')),
        );
      }
    }
  }

  Future<void> _selectBetrieb(Map<String, dynamic> betrieb) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_betrieb_id', betrieb['betrieb_id']);
    await prefs.setString('selected_betrieb_name', betrieb['betriebe']['name']);

    ref.read(selectedBetriebProvider.notifier).state = betrieb['betrieb_id'];

    await supabase
        .from('user_betrieb')
        .update({'last_used': DateTime.now().toIso8601String()})
        .eq('user_id', ref.read(authProvider)!.id)
        .eq('betrieb_id', betrieb['betrieb_id']);

    if (!mounted) return;

    final user = ref.read(authProvider);
    if (user?.role == 'admin' || user?.role == 'manager') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmployeeHomePage()),
      );
    }
  }

  Future<void> _deleteBetrieb(Map<String, dynamic> betrieb, int index) async {
    final name = betrieb['betriebe']['name'] ?? 'diesen Betrieb';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Betrieb löschen?'),
        content: Text('Möchten Sie „$name“ wirklich löschen?\nAlle Daten gehen verloren!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('betriebe').delete().eq('id', betrieb['betrieb_id']);
      await supabase.from('user_betrieb').delete().eq('betrieb_id', betrieb['betrieb_id']);

      setState(() {
        _betriebe.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name gelöscht')),
        );
      }
    } catch (e) {
      print('Fehler beim Löschen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e')),
        );
      }
    }
  }

  Future<void> _editBetrieb(Map<String, dynamic> betrieb) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BetriebBearbeitenPage(betrieb: betrieb),
    ),
  );

  if (result == true && mounted) {
    _loadBetriebe(); // Liste neu laden nach Bearbeiten
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Betrieb auswählen'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _betriebe.isEmpty
              ? const Center(
                  child: Text(
                    'Kein Betrieb zugewiesen.\nBitte wenden Sie sich an den Admin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _betriebe.length,
                  itemBuilder: (context, index) {
                    final betrieb = _betriebe[index];
                    final betriebsData = betrieb['betriebe'] as Map<String, dynamic>;

                    return Dismissible(
                      key: Key(betrieb['betrieb_id'].toString()),
                      direction: DismissDirection.horizontal,

                      // Rechts → Löschen (roter Hintergrund)
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white, size: 32),
                      ),

                      // Links → Bearbeiten (grüner Hintergrund)
                      secondaryBackground: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.edit, color: Colors.white, size: 32),
                      ),

                      confirmDismiss: (direction) async {
                        // Rechts → Löschen → Bestätigung
                        if (direction == DismissDirection.startToEnd) {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Betrieb löschen?'),
                              content: Text(
                                'Möchten Sie „${betriebsData['name']}“ wirklich löschen?\nAlle Daten gehen verloren!',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Abbrechen'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Löschen'),
                                ),
                              ],
                            ),
                          ) ?? false;
                        }

                        // Links → Bearbeiten → Karte bleibt stehen
                        if (direction == DismissDirection.endToStart) {
                          await _editBetrieb(betrieb);
                          return false; // Kein Dismiss – Karte bleibt!
                        }

                        return false;
                      },

                      onDismissed: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await _deleteBetrieb(betrieb, index);
                        }
                      },

                      movementDuration: const Duration(milliseconds: 300),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              (betriebsData['name'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                              style: TextStyle(color: Colors.green.shade800),
                            ),
                          ),
                          title: Text(
                            betriebsData['name'] ?? 'Unbekannter Betrieb',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${betriebsData['ort'] ?? ''} • ${betrieb['rolle']?.toUpperCase() ?? ''}',
                          ),
                          trailing: betrieb['is_favorit'] == true
                              ? const Icon(Icons.star, color: Colors.amber)
                              : null,
                          onTap: () => _selectBetrieb(betrieb),
                        ),
                      ),
                    );
                  },
                ),

      floatingActionButton: ref.read(authProvider)?.role == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BetriebAnlegenPage()),
                );
                if (result == true) {
                  _loadBetriebe();
                }
              },
              child: const Icon(Icons.add),
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              tooltip: 'Neuen Betrieb anlegen',
            )
          : null,
    );
  }
}