import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hygiene_app/providers/auth_provider.dart';
import '../../providers/auth_provider.dart';

import '../../core/supabase_client.dart';
import '../../providers/auth_provider.dart';
import '../../providers/selected_betrieb_provider.dart';

import '../dashboard/admin_dashboard_page.dart';
import '../dashboard/pages/employee_home_page.dart';
import 'betrieb_anlegen_page.dart';
import 'betrieb_bearbeiten_page.dart';
import '../../../providers/auth_provider.dart';


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
            betriebe!inner (
              id, 
              name, 
              adresse, 
              plz, 
              ort, 
              telefon, 
              email,
              betriebsart_id,
              betriebsunterkategorie_id,
              haccp_verantwortlich,
              sonstiges
            )
          ''')
          .eq('user_id', user.id)
          .order('is_favorit', ascending: false)
          .order('last_used', ascending: false, nullsFirst: true);

      setState(() {
        _betriebe = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
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

    final id = betrieb['betrieb_id'] as String;
    final name = (betrieb['betriebe']?['name'] ?? '') as String;

    await prefs.setString('selected_betrieb_id', id);
    await prefs.setString('selected_betrieb_name', name);

    await ref.read(selectedBetriebIdProvider.notifier).set(id);

    // last_used aktualisieren
    await supabase
        .from('user_betrieb')
        .update({'last_used': DateTime.now().toIso8601String()})
        .eq('user_id', ref.read(authProvider)!.id)
        .eq('betrieb_id', id);

    if (!mounted) return;

    final user = ref.read(authProvider);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => (user?.role == 'admin' || user?.role == 'manager')
            ? const AdminDashboardPage()
            : const EmployeeHomePage(),
      ),
    );
  }

  Future<void> _editBetrieb(Map<String, dynamic> betrieb) async {
    final betriebId = betrieb['betrieb_id'] as String;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BetriebBearbeitenPage(betriebId: betriebId),   // Nur ID übergeben
      ),
    );

    if (result == true && mounted) {
      _loadBetriebe();   // Liste neu laden nach erfolgreicher Bearbeitung
    }
  }

  Future<void> _deleteBetrieb(Map<String, dynamic> betrieb, int index) async {
    final name = (betrieb['betriebe']?['name'] ?? 'diesen Betrieb') as String;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Betrieb löschen?'),
        content: Text('Möchten Sie „$name“ wirklich löschen?\nAlle Daten gehen verloren!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('betriebe').delete().eq('id', betrieb['betrieb_id']);
      await supabase.from('user_betrieb').delete().eq('betrieb_id', betrieb['betrieb_id']);

      setState(() => _betriebe.removeAt(index));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name wurde gelöscht')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider);

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
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _betriebe.length,
                  itemBuilder: (context, index) {
                    final betrieb = _betriebe[index];
                    final data = betrieb['betriebe'] as Map<String, dynamic>? ?? {};

                    return Dismissible(
                      key: Key(betrieb['betrieb_id'].toString()),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Betrieb löschen?'),
                                  content: Text('Möchten Sie „${data['name']}“ wirklich löschen?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
                                  ],
                                ),
                              ) ??
                              false;
                        }
                        if (direction == DismissDirection.endToStart) {
                          await _editBetrieb(betrieb);
                          return false;
                        }
                        return false;
                      },
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await _deleteBetrieb(betrieb, index);
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              (data['name'] as String? ?? '?').substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                          title: Text(data['name'] ?? 'Unbekannt'),
                          subtitle: Text('${data['ort'] ?? ''} • ${betrieb['rolle'] ?? ''}'),
                          trailing: betrieb['is_favorit'] == true
                              ? const Icon(Icons.star, color: Colors.amber)
                              : null,
                          onTap: () => _selectBetrieb(betrieb),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: user?.role == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BetriebAnlegenPage()),
                );
                if (result == true) _loadBetriebe();
              },
              backgroundColor: Colors.green.shade700,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}