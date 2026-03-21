import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';

class BetriebBearbeitenPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> betrieb;

  const BetriebBearbeitenPage({super.key, required this.betrieb});

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

  int? _selectedBetriebsartId;
  bool _haccpVerantwortlich = true;

  bool _isLoading = false;
  List<Map<String, dynamic>> _betriebsarten = [];

  @override
  void initState() {
    super.initState();

    final betriebsData = widget.betrieb['betriebe'] ?? {};

    _nameController = TextEditingController(text: betriebsData['name'] ?? '');
    _adresseController = TextEditingController(text: betriebsData['adresse'] ?? '');
    _plzController = TextEditingController(text: betriebsData['plz'] ?? '');
    _ortController = TextEditingController(text: betriebsData['ort'] ?? '');
    _telefonController = TextEditingController(text: betriebsData['telefon'] ?? '');
    _emailController = TextEditingController(text: betriebsData['email'] ?? '');

    _selectedBetriebsartId = betriebsData['betriebsart_id'];
    _haccpVerantwortlich = betriebsData['haccp_verantwortlich'] ?? true;

    _loadBetriebsarten();
  }

  Future<void> _loadBetriebsarten() async {
    try {
      final response = await supabase.from('betriebsarten').select('id, name').order('name');

      setState(() {
        _betriebsarten = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Fehler beim Laden der Betriebsarten: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden: $e')),
        );
      }
    }
  }

  Future<void> _updateBetrieb() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await supabase
          .from('betriebe')
          .update({
            'name': _nameController.text.trim(),
            'betriebsart_id': _selectedBetriebsartId,
            'adresse': _adresseController.text.trim(),
            'plz': _plzController.text.trim(),
            'ort': _ortController.text.trim(),
            'telefon': _telefonController.text.trim(),
            'email': _emailController.text.trim(),
            'haccp_verantwortlich': _haccpVerantwortlich,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.betrieb['betrieb_id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Betrieb aktualisiert!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // true = neu laden
      }
    } catch (e) {
      print('Update-Fehler: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      decoration: const InputDecoration(labelText: 'Betriebsname *', border: OutlineInputBorder()),
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Pflichtfeld' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
  value: _selectedBetriebsartId,
  decoration: const InputDecoration(
    labelText: 'Betriebsart *',
    border: OutlineInputBorder(),
  ),
  items: _betriebsarten.map<DropdownMenuItem<int>>((art) {
    return DropdownMenuItem<int>(
      value: art['id'] as int,
      child: Text(art['name'] as String),
    );
  }).toList(),
  onChanged: (v) => setState(() => _selectedBetriebsartId = v),
  validator: (v) => v == null ? 'Pflichtfeld' : null,
),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _adresseController,
                      decoration: const InputDecoration(labelText: 'Straße & Hausnummer', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _plzController,
                            decoration: const InputDecoration(labelText: 'PLZ', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ortController,
                            decoration: const InputDecoration(labelText: 'Ort', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _telefonController,
                      decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-Mail', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    SwitchListTile(
                      title: const Text('HACCP-Verantwortung'),
                      subtitle: const Text('Ist der Admin/Betriebsleiter für HACCP verantwortlich?'),
                      value: _haccpVerantwortlich,
                      onChanged: (v) => setState(() => _haccpVerantwortlich = v),
                      activeColor: Colors.green.shade700,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateBetrieb,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Änderungen speichern', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}