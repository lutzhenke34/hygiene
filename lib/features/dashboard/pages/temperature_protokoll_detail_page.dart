import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TemperatureProtokollDetailPage extends StatefulWidget {
  final String protokollName;
  final String betriebId;

  const TemperatureProtokollDetailPage({
    super.key,
    required this.protokollName,
    required this.betriebId,
  });

  @override
  State<TemperatureProtokollDetailPage> createState() => _TemperatureProtokollDetailPageState();
}

class _TemperatureProtokollDetailPageState extends State<TemperatureProtokollDetailPage> {
  final DateTime _currentMonth = DateTime.now();
  final Map<int, Map<String, String>> _temperaturen = {}; // Tag → (Gerät → Temperatur)

  final List<String> _geraete = [
    'Gemüse',
    'Fleisch',
    'Molkerei',
    'Tages',
    'Bankett',
    // Hier kannst du später dynamisch aus den angelegten Kühlgeräten laden
  ];

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy', 'de_DE').format(_currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.protokollName),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header wie auf dem Foto
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperaturliste / Hauptküche',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  monthName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Tabelle
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                  columns: [
                    const DataColumn(label: Text('Tag', style: TextStyle(fontWeight: FontWeight.bold))),
                    ..._geraete.map((g) => DataColumn(label: Text(g, style: const TextStyle(fontWeight: FontWeight.bold)))),
                    const DataColumn(label: Text('Maßnahme')),
                    const DataColumn(label: Text('Kürzel')),
                    const DataColumn(label: Text('Uhrzeit')),
                  ],
                  rows: List.generate(31, (index) {
                    final tag = index + 1;
                    return DataRow(
                      cells: [
                        DataCell(Text('$tag')),
                        ..._geraete.map((geraet) {
                          final wert = _temperaturen[tag]?[geraet] ?? '';
                          return DataCell(
                            TextFormField(
                              initialValue: wert,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                _temperaturen.putIfAbsent(tag, () => {});
                                _temperaturen[tag]![geraet] = value;
                              },
                            ),
                          );
                        }),
                        const DataCell(Text('')),   // Maßnahme
                        const DataCell(Text('')),   // Kürzel
                        const DataCell(Text('')),   // Uhrzeit
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Hier später speichern in Supabase
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Protokoll gespeichert (kommt bald)')),
          );
        },
        label: const Text('Speichern'),
        icon: const Icon(Icons.save),
        backgroundColor: Colors.green,
      ),
    );
  }
}