import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hygiene_app/providers/auth_provider.dart';
import 'package:hygiene_app/providers/selected_betrieb_provider.dart';
import 'package:hygiene_app/providers/mitarbeiter_provider.dart';

import 'hygiene_aufgaben_page.dart';
import '../models/mitarbeiter.dart';

class EmployeeHomePage extends ConsumerStatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  ConsumerState<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends ConsumerState<EmployeeHomePage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBetrieb();
  }

  Future<void> _loadBetrieb() async {
    try {
      final user = ref.read(authProvider);
      if (user == null) {
        setState(() {
          _errorMessage = "Nicht eingeloggt";
          _isLoading = false;
        });
        return;
      }

      // Betrieb des Mitarbeiters laden
      final response = await Supabase.instance.client
          .from('mitarbeiter')
          .select('betrieb_id')
          .eq('id', user.id)
          .maybeSingle();

      final betriebId = response?['betrieb_id'] as String?;

      if (betriebId != null && betriebId.isNotEmpty) {
        ref.read(selectedBetriebIdProvider.notifier).set(betriebId);
      } else {
        setState(() => _errorMessage = "Kein Betrieb zugewiesen. Bitte Admin kontaktieren.");
      }
    } catch (e) {
      debugPrint('Fehler beim Laden des Betriebs: $e');
      setState(() => _errorMessage = "Fehler beim Laden: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final betriebIdAsync = ref.watch(selectedBetriebIdProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Nicht eingeloggt')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Aufgaben'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: betriebIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Betrieb-Fehler: $e')),
        data: (betriebId) {
          if (betriebId == null || betriebId.isEmpty) {
            return const Center(
              child: Text('Kein Betrieb zugewiesen.\n\nBitte Admin kontaktieren.', textAlign: TextAlign.center),
            );
          }

          final mitarbeiterAsync = ref.watch(mitarbeiterNotifierProvider(betriebId));

          return mitarbeiterAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Fehler: $e')),
            data: (mitarbeiterListe) {
              final current = mitarbeiterListe.firstWhere(
                (m) => m.id == user.id,
                orElse: () => Mitarbeiter(
                  id: '',
                  betriebId: betriebId,
                  vorname: '',
                  nachname: '',
                  canManageHygiene: false,
                  canManageGeraete: false,
                  canViewAllProtokolle: false,
                ),
              );

              final vorname = current.vorname.isNotEmpty 
                  ? current.vorname 
                  : (user.name?.split(' ').first ?? 'Mitarbeiter');

              final canHygiene = current.canManageHygiene ?? false;
              final canAufgaben = current.canManageGeraete ?? false;
              final canProtokolle = current.canViewAllProtokolle ?? false;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hallo $vorname!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Rolle: ${current.rolle ?? user.role ?? "Mitarbeiter"}', 
                         style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 40),

                    if (!canHygiene && !canAufgaben && !canProtokolle)
                      const Center(child: Text('Keine Berechtigungen vorhanden.\nBitte kontaktieren Sie den Admin.', textAlign: TextAlign.center))
                    else
                      Column(
                        children: [
                          if (canHygiene)
                            _buildBigKachel('Hygieneaufgaben', Icons.clean_hands, Colors.green, () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => HygieneAufgabenPage(betriebId: betriebId)));
                            }),
                          const SizedBox(height: 16),
                          if (canAufgaben)
                            _buildBigKachel('Meine Aufgaben', Icons.checklist, Colors.orange, () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kommt bald')));
                            }),
                          const SizedBox(height: 16),
                          if (canProtokolle)
                            _buildBigKachel('Protokolle', Icons.assignment_turned_in, Colors.purple, () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kommt bald')));
                            }),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBigKachel(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(radius: 36, backgroundColor: color.withOpacity(0.15), child: Icon(icon, size: 40, color: color)),
              const SizedBox(width: 24),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}