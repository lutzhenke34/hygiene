import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/mitarbeiter_provider.dart';
import '../../../providers/hygiene_aufgabe_provider.dart';

import '../models/mitarbeiter.dart';
import '../models/hygiene_aufgabe.dart';
import 'temperature_protokoll_detail_page.dart';

class HaccpProtokollePage extends ConsumerWidget {
  final String betriebId;

  const HaccpProtokollePage({super.key, required this.betriebId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mitarbeiterAsync = ref.watch(mitarbeiterNotifierProvider(betriebId));
    final hygieneAsync = ref.watch(hygieneAufgabeNotifierProvider(betriebId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('HACCP Protokolle'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: mitarbeiterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler beim Laden: $e')),
        data: (mitarbeiter) {
          return hygieneAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Fehler bei Protokollen: $e')),
            data: (hygieneAufgaben) {
              // Nur echte Protokolle mit protokollName
              final Map<String, List<HygieneAufgabe>> protokollMap = {};

              for (var aufgabe in hygieneAufgaben) {
                final name = aufgabe.protokollName?.trim();
                if (name == null || name.isEmpty) continue;
                protokollMap.putIfAbsent(name, () => []).add(aufgabe);
              }

              final protokollListe = protokollMap.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mitarbeiter Hygiene-Status',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...mitarbeiter.map((m) => _buildMitarbeiterCard(m)),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'HACCP Protokolle',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('${protokollListe.length} Protokolle'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (protokollListe.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Text(
                            'Noch keine HACCP-Protokolle angelegt.\n\n'
                            'Erstelle in den Hygieneaufgaben eine Aufgabe und weise ihr ein Protokoll zu.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: protokollListe.length,
                        itemBuilder: (context, index) {
                          final entry = protokollListe[index];
                          final offen = entry.value.where((a) => !a.erledigt).length;
                          final isTemperature = entry.key.toLowerCase().contains('temperatur') ||
                                               entry.key.toLowerCase().contains('kühl');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: isTemperature 
                                    ? Colors.orange.shade100 
                                    : Colors.blue.shade100,
                                child: Icon(
                                  isTemperature 
                                      ? Icons.thermostat_rounded 
                                      : Icons.shield_outlined,
                                  color: isTemperature ? Colors.orange : Colors.blue,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              subtitle: Text('${entry.value.length} Einträge • $offen offen'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TemperatureProtokollDetailPage(
                                      protokollName: entry.key,
                                      betriebId: betriebId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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

  Widget _buildMitarbeiterCard(Mitarbeiter m) {
    final hatAusweis = m.hygieneausweisUrl != null && m.hygieneausweisUrl!.isNotEmpty;
    final schulungAlt = m.letzteSchulung != null &&
        DateTime.now().difference(m.letzteSchulung!).inDays > 365;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hatAusweis ? Colors.green : Colors.red,
          child: Icon(hatAusweis ? Icons.verified : Icons.warning, color: Colors.white),
        ),
        title: Text('${m.vorname} ${m.nachname}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hygieneausweis: ${hatAusweis ? "vorhanden" : "fehlt"}'),
            if (m.letzteSchulung != null)
              Text(
                'Letzte Schulung: ${m.letzteSchulung!.toString().split(" ")[0]}'
                '${schulungAlt ? "  ⚠️ (älter als 1 Jahr)" : ""}',
              ),
          ],
        ),
      ),
    );
  }
}