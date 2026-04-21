// lib/features/dashboard/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/selected_betrieb_provider.dart';
import '../../providers/mitarbeiter_provider.dart';
import '../../providers/hygiene_aufgabe_provider.dart';
import '../../providers/aufgabe_provider.dart';
import '../../providers/mitarbeiter_online_provider.dart';
import '../../providers/auth_provider.dart';

import '../betrieb/betrieb_auswahl_page.dart';
import 'verwaltung_page.dart';
import 'pages/mitarbeiter_verwaltung_page.dart';
import 'pages/hygiene_aufgaben_page.dart';
import 'pages/haccp_protokolle_page.dart';
import 'pages/schichten_verwaltung_page.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}

class _AdminDashboardPageState
    extends ConsumerState<AdminDashboardPage> {
  String? _betriebName;

  @override
  void initState() {
    super.initState();
    _clearOldTestData();
    _loadSelectedBetriebName();
  }

  Future<void> _clearOldTestData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_betrieb_id') == 'test') {
      await prefs.remove('selected_betrieb_id');
    }
  }

  Future<void> _loadSelectedBetriebName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('selected_betrieb_name');
    final id = prefs.getString('selected_betrieb_id');

    if (mounted) {
      setState(() {
        _betriebName =
            name ?? (id != null ? 'Le Pot' : 'Kein Betrieb ausgewählt');
      });
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abmelden?'),
        content: const Text('Möchten Sie sich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final betriebIdAsync = ref.watch(selectedBetriebIdProvider);

    return Scaffold(
      body: betriebIdAsync.when(
        data: (betriebId) {
          if (betriebId == null || betriebId.isEmpty) {
            return const Center(
              child: Text(
                'Bitte zuerst einen Betrieb auswählen',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return _buildContent(context, betriebId);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String betriebId) {
    final mitarbeiterAsync =
        ref.watch(mitarbeiterNotifierProvider(betriebId));
    final hygieneAsync =
        ref.watch(hygieneAufgabeNotifierProvider(betriebId));
    final aufgabenAsync =
        ref.watch(aufgabeNotifierProvider(betriebId));
    final onlineAsync =
        ref.watch(onlineMitarbeiterProvider(betriebId));

    return mitarbeiterAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('Fehler beim Laden: $e')),
      data: (mitarbeiterListe) {
        final totalMitarbeiter = mitarbeiterListe.length;

        // ✅ WICHTIG: korrektes Handling
        final eingeloggte = onlineAsync.when(
          data: (v) => v,
          loading: () => 0,
          error: (_, __) => 0,
        );

        final offeneHygiene = hygieneAsync.value
                ?.where((a) => !a.erledigt)
                .length ??
            0;
        final gesamtHygiene =
            hygieneAsync.value?.length ?? 0;

        final offeneAufgaben = aufgabenAsync.value
                ?.where((a) => !a.erledigt)
                .length ??
            0;
        final gesamtAufgaben =
            aufgabenAsync.value?.length ?? 0;

        return Column(
          children: [
            // HEADER bleibt unverändert
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(16, 50, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      Text(
                        'HACCP Protokolle',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: Colors.white),
                        tooltip: 'Abmelden',
                        onPressed: _logout,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _betriebName ?? 'Le Pot',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const BetriebAuswahlPage()),
                      );
                      await _loadSelectedBetriebName();
                    },
                    icon: const Icon(Icons.swap_horiz,
                        color: Colors.blue),
                    label:
                        const Text('Betrieb wechseln'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT bleibt gleich
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Übersicht – ${_betriebName ?? 'Le Pot'}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                            color: Colors
                                .green.shade800,
                          ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatKachel(
                          icon: Icons.people,
                          label: 'Mitarbeiter',
                          current: eingeloggte,
                          total: totalMitarbeiter,
                          color: Colors.blue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MitarbeiterVerwaltungPage(
                                      betriebId:
                                          betriebId),
                            ),
                          ),
                        ),
                        _buildStatKachel(
                          icon: Icons.description,
                          label: 'Hygiene',
                          current: offeneHygiene,
                          total: gesamtHygiene,
                          color: Colors.green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  HygieneAufgabenPage(
                                      betriebId:
                                          betriebId),
                            ),
                          ),
                        ),
                        _buildStatKachel(
                          icon: Icons.checklist,
                          label: 'Aufgaben',
                          current: offeneAufgaben,
                          total: gesamtAufgaben,
                          color: Colors.orange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const VerwaltungPage(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const VerwaltungPage(),
                          ),
                        ),
                        icon: const Icon(Icons.settings,
                            size: 26),
                        label:
                            const Text('Verwaltung'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green.shade800,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 18),
                          textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w600),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatKachel({
    required IconData icon,
    required String label,
    required int current,
    required int total,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 12),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      color.withOpacity(0.12),
                  child: Icon(icon,
                      size: 34,
                      color: color),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                      fontSize: 15),
                  textAlign:
                      TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '$current / $total',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}