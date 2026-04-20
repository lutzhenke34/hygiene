import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';

class BetriebBearbeitenPage extends ConsumerStatefulWidget {
  final String betriebId;   // Wir übergeben nur die ID, laden dann frisch

  const BetriebBearbeitenPage({super.key, required this.betriebId});

  @override
  ConsumerState<BetriebBearbeitenPage> createState() => _BetriebBearbeitenPageState();
}

class _BetriebBearbeitenPageState extends ConsumerState<BetriebBearbeitenPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _adresseController;
  late TextEditingController _plzController;
  late TextEditingController _ortController;
  late TextEditingController _telefonController;
  late TextEditingController _emailController;
  late TextEditingController _sonstigesController;

  int? _selectedHauptkategorieId;
  int? _selectedUnterkategorieId;
  bool _haccpVerantwortlich = true;
  bool _showSonstigesFreitext = false;

  bool _isLoading = false;
  bool _isDataLoading = true;

  List<Map<String, dynamic>> _hauptkategorien = [];
  List<Map<String, dynamic>> _unterkategorien = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _adresseController = TextEditingController();
    _plzController = TextEditingController();
    _ortController = TextEditingController();
    _telefonController = TextEditingController();
    _emailController = TextEditingController();
    _sonstigesController = TextEditingController();

    _loadBetriebData();        // Frisch laden aus Supabase
    _loadHauptkategorien();
  }

  // NEU: Frisches Laden der Betriebsdaten aus der Datenbank
  Future<void> _loadBetriebData() async {
    try {
      final res = await supabase
          .from('betriebe')
          .select()
          .eq('id', widget.betriebId)
          .single();

      final data = res;

      setState(() {
        _nameController.text = data['name']?.toString() ?? '';
        _adresseController.text = data['adresse']?.toString() ?? '';
        _plzController.text = data['plz']?.toString() ?? '';
        _ortController.text = data['ort']?.toString() ?? '';
        _telefonController.text = data['telefon']?.toString() ?? '';
        _emailController.text = data['email']?.toString() ?? '';
        _sonstigesController.text = data['sonstiges']?.toString() ?? '';

        _selectedHauptkategorieId = data['betriebsart_id'] as int?;
        _selectedUnterkategorieId = data['betriebsunterkategorie_id'] as int?;
        _haccpVerantwortlich = data['haccp_verantwortlich'] ?? true;

        _showSonstigesFreitext = (_selectedUnterkategorieId == null) && 
                                 (data['sonstiges']?.toString().isNotEmpty ?? false);

        _isDataLoading = false;
      });

      if (_selectedHauptkategorieId != null) {
        _loadUnterkategorien(_selectedHauptkategorieId);
      }
    } catch (e) {
      print('Fehler beim Laden des Betriebs: $e');
      setState(() => _isDataLoading = false);
    }
  }

  Future<void> _loadHauptkategorien() async {
    try {
      final res = await supabase.from('betriebsarten').select('id, name').order('name');
      setState(() => _hauptkategorien = List<Map<String, dynamic>>.from(res));
    } catch (e) {
      print('Fehler Hauptkategorien: $e');
    }
  }

  Future<void> _loadUnterkategorien(int? hauptkategorieId) async {
    if (hauptkategorieId == null) return;

    try {
      final res = await supabase
          .from('betriebsunterkategorien')
          .select('id, name')
          .eq('betriebsart_id', hauptkategorieId)
          .order('name');

      setState(() {
        _unterkategorien = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      print('Fehler Unterkategorien: $e');
    }
  }

  Future<void> _updateBetrieb() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await supabase.from('betriebe').update({
        'name': _nameController.text.trim(),
        'betriebsart_id': _selectedHauptkategorieId,
        'betriebsunterkategorie_id': _selectedUnterkategorieId,
        'sonstiges': _showSonstigesFreitext ? _sonstigesController.text.trim() : null,
        'adresse': _adresseController.text.trim(),
        'plz': _plzController.text.trim(),
        'ort': _ortController.text.trim(),
        'telefon': _telefonController.text.trim(),
        'email': _emailController.text.trim(),
        'haccp_verantwortlich': _haccpVerantwortlich,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.betriebId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Betrieb erfolgreich aktualisiert'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Update-Fehler: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _adresseController.dispose();
    _plzController.dispose();
    _ortController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    _sonstigesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Betrieb bearbeiten'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Betriebsname *'),
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Pflichtfeld' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      value: _hauptkategorien.any((e) => e['id'] == _selectedHauptkategorieId)
                          ? _selectedHauptkategorieId
                          : null,
                      decoration: const InputDecoration(labelText: 'Hauptkategorie'),
                      items: _hauptkategorien.map((e) {
                        return DropdownMenuItem<int>(
                          value: e['id'] as int,
                          child: Text(e['name'] as String),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedHauptkategorieId = val;
                          _selectedUnterkategorieId = null;
                          _showSonstigesFreitext = false;
                        });
                        _loadUnterkategorien(val);
                      },
                    ),
                    const SizedBox(height: 16),

                    if (_selectedHauptkategorieId != null)
                      DropdownButtonFormField<int>(
                        value: _unterkategorien.any((u) => u['id'] == _selectedUnterkategorieId)
                            ? _selectedUnterkategorieId
                            : null,
                        decoration: const InputDecoration(labelText: 'Unterkategorie'),
                        items: [
                          ..._unterkategorien.map((e) => DropdownMenuItem<int>(
                                value: e['id'] as int,
                                child: Text(e['name'] as String),
                              )),
                          const DropdownMenuItem<int>(value: 0, child: Text('Sonstiges (Freitext)')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            if (val == 0) {
                              _selectedUnterkategorieId = null;
                              _showSonstigesFreitext = true;
                            } else {
                              _selectedUnterkategorieId = val;
                              _showSonstigesFreitext = false;
                            }
                          });
                        },
                      ),

                    if (_showSonstigesFreitext) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sonstigesController,
                        decoration: const InputDecoration(labelText: 'Sonstiges'),
                        maxLines: 3,
                      ),
                    ],

                    const SizedBox(height: 24),

                    TextFormField(controller: _adresseController, decoration: const InputDecoration(labelText: 'Adresse')),
                    const SizedBox(height: 16),

                    TextFormField(controller: _plzController, decoration: const InputDecoration(labelText: 'PLZ'), keyboardType: TextInputType.number),
                    const SizedBox(height: 16),

                    TextFormField(controller: _ortController, decoration: const InputDecoration(labelText: 'Ort')),
                    const SizedBox(height: 16),

                    TextFormField(controller: _telefonController, decoration: const InputDecoration(labelText: 'Telefon'), keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),

                    TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-Mail'), keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 24),

                    SwitchListTile(
                      title: const Text('HACCP-Verantwortlich'),
                      value: _haccpVerantwortlich,
                      onChanged: (v) => setState(() => _haccpVerantwortlich = v),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _updateBetrieb,
                      child: const Text('Änderungen speichern'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}