import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hygiene_app/providers/auth_provider.dart';
import 'package:hygiene_app/providers/selected_betrieb_provider.dart';
import 'package:hygiene_app/providers/mitarbeiter_provider.dart';
import 'package:hygiene_app/providers/aufgabe_provider.dart';
import 'package:hygiene_app/providers/hygiene_aufgabe_provider.dart';

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
          _errorMessage = 'Nicht eingeloggt';
          _isLoading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('mitarbeiter')
          .select('betrieb_id')
          .eq('id', user.id)
          .maybeSingle();

      final betriebId = response?['betrieb_id'] as String?;

      if (betriebId != null && betriebId.isNotEmpty) {
        await ref.read(selectedBetriebIdProvider.notifier).set(betriebId);
      } else {
        setState(() {
          _errorMessage = 'Kein Betrieb zugewiesen. Bitte Admin kontaktieren.';
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Laden des Betriebs: $e');
      setState(() {
        _errorMessage = 'Fehler beim Laden: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      return const Scaffold(
        body: Center(child: Text('Nicht eingeloggt')),
      );
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
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
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
              child: Text(
                'Kein Betrieb zugewiesen.\n\nBitte Admin kontaktieren.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final mitarbeiterAsync =
              ref.watch(mitarbeiterNotifierProvider(betriebId));

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
              final aktuelleRolle =
                  current.rolle?.trim().isNotEmpty == true
                      ? current.rolle!.trim()
                      : (user.role ?? '').trim();

              final employeeAufgabenAsync = ref.watch(
                employeeAufgabenProvider(
                  (betriebId: betriebId, rolle: aktuelleRolle),
                ),
              );

              final employeeHygieneAufgabenAsync = ref.watch(
                employeeHygieneAufgabenProvider(
                  (betriebId: betriebId, rolle: aktuelleRolle),
                ),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hallo $vorname!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rolle: ${aktuelleRolle.isNotEmpty ? aktuelleRolle : "Mitarbeiter"}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _buildOverviewTile(
                            context: context,
                            title: 'Aufgaben',
                            subtitle: 'Offene Aufgaben',
                            icon: Icons.assignment,
                            color: Colors.green,
                            countAsync: employeeAufgabenAsync,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EmployeeTaskListPage(
                                    betriebId: betriebId,
                                    rolle: aktuelleRolle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildOverviewTile(
                            context: context,
                            title: 'Hygiene',
                            subtitle: 'Offene Hygieneaufgaben',
                            icon: Icons.cleaning_services,
                            color: Colors.blue,
                            countAsync: employeeHygieneAufgabenAsync,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EmployeeHygieneTaskListPage(
                                    betriebId: betriebId,
                                    rolle: aktuelleRolle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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

  Widget _buildOverviewTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required AsyncValue<List<dynamic>> countAsync,
    required VoidCallback onTap,
  }) {
    final count = countAsync.when(
      data: (items) => items.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmployeeTaskListPage extends ConsumerWidget {
  final String betriebId;
  final String rolle;

  const EmployeeTaskListPage({
    super.key,
    required this.betriebId,
    required this.rolle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aufgabenAsync = ref.watch(
      employeeAufgabenProvider((betriebId: betriebId, rolle: rolle)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Aufgaben'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: aufgabenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (aufgaben) {
          if (aufgaben.isEmpty) {
            return const Center(
              child: Text(
                'Für Ihre aktuelle Rolle und Schicht gibt es gerade keine offenen Aufgaben.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: aufgaben.length,
            itemBuilder: (context, index) {
              final a = aufgaben[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.assignment,
                    color: Colors.orange,
                    size: 30,
                  ),
                  title: Text(
                    a.titel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (a.beschreibung != null && a.beschreibung!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(a.beschreibung!),
                        ),
                      if (a.faelligBis != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Fällig bis: ${a.faelligBis!.toString().split(' ')[0]}',
                          ),
                        ),
                      if (a.rolle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Rolle: ${a.rolle}'),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      await ref
                          .read(aufgabeNotifierProvider(betriebId).notifier)
                          .toggleErledigt(a.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EmployeeHygieneTaskListPage extends ConsumerWidget {
  final String betriebId;
  final String rolle;

  const EmployeeHygieneTaskListPage({
    super.key,
    required this.betriebId,
    required this.rolle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aufgabenAsync = ref.watch(
      employeeHygieneAufgabenProvider((betriebId: betriebId, rolle: rolle)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Hygieneaufgaben'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: aufgabenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (aufgaben) {
          if (aufgaben.isEmpty) {
            return const Center(
              child: Text(
                'Für Ihre aktuelle Rolle und Schicht gibt es gerade keine offenen Hygieneaufgaben.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: aufgaben.length,
            itemBuilder: (context, index) {
              final a = aufgaben[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.cleaning_services,
                    color: Colors.blue,
                    size: 30,
                  ),
                  title: Text(
                    a.titel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (a.beschreibung != null && a.beschreibung!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(a.beschreibung!),
                        ),
                      if (a.faelligBis != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Fällig bis: ${a.faelligBis!.toString().split(' ')[0]}',
                          ),
                        ),
                      if (a.rolle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Rolle: ${a.rolle}'),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      await ref
                          .read(
                            hygieneAufgabeNotifierProvider(betriebId).notifier,
                          )
                          .toggleErledigt(a.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
