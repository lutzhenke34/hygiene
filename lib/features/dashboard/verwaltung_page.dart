import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/selected_betrieb_provider.dart';

import '../dashboard/pages/mitarbeiter_verwaltung_page.dart';
import '../dashboard/pages/kuehlgeraete_verwaltung_page.dart';
import '../dashboard/pages/geraete_verwaltung_page.dart';
import '../dashboard/pages/hygiene_aufgaben_page.dart';
import '../dashboard/pages/aufgaben_page.dart';
import '../dashboard/pages/schichten_verwaltung_page.dart';   // ← NEU hinzugefügt

class VerwaltungPage extends ConsumerWidget {
  const VerwaltungPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final betriebIdAsync = ref.watch(selectedBetriebIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verwaltung'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: betriebIdAsync.when(
        data: (betriebId) {
          if (betriebId == null || betriebId.isEmpty) {
            return const Center(child: Text("Kein Betrieb ausgewählt"));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildVerwaltungKachel(
                  context: context,
                  icon: Icons.calendar_today,
                  title: 'Ruhetage & Schichten',
                  subtitle: 'Planen',
                  color: Colors.blue.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SchichtenVerwaltungPage(betriebId: betriebId),
                      ),
                    );
                  },
                ),
                _buildVerwaltungKachel(
                  context: context,
                  icon: Icons.people,
                  title: 'Mitarbeiter',
                  subtitle: 'Verwalten',
                  color: Colors.blue.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MitarbeiterVerwaltungPage(betriebId: betriebId),
                      ),
                    );
                  },
                ),
                _buildVerwaltungKachel(
                  context: context,
                  icon: Icons.kitchen,
                  title: 'Kühlgeräte',
                  subtitle: 'Kontrolle',
                  color: Colors.cyan.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KuehlgeraeteVerwaltungPage(betriebId: betriebId),
                      ),
                    );
                  },
                ),
                _buildVerwaltungKachel(
                  context: context,
                  icon: Icons.build,
                  title: 'Geräte',
                  subtitle: 'Übersicht',
                  color: Colors.teal.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GeraeteVerwaltungPage(betriebId: betriebId),
                      ),
                    );
                  },
                ),
                _buildVerwaltungKachel(
                  context: context,
                  icon: Icons.description,
                  title: 'Hygiene',
                  subtitle: 'Aufgaben',
                  color: Colors.green.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HygieneAufgabenPage(betriebId: betriebId),
                      ),
                    );
                  },
                ),
                _buildVerwaltungKachel(
                  context: context,
                  icon: Icons.checklist,
                  title: 'Aufgaben',
                  subtitle: 'Anweisungen',
                  color: Colors.orange.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AufgabenPage(betriebId: betriebId),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Fehler: $e")),
      ),
    );
  }

  Widget _buildVerwaltungKachel({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade800),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}