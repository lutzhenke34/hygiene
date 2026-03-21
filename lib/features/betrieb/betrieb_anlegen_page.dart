import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';
import '../../providers/auth_provider.dart';

class BetriebAnlegenPage extends ConsumerStatefulWidget {
  const BetriebAnlegenPage({super.key});

  @override
  ConsumerState<BetriebAnlegenPage> createState() => _BetriebAnlegenPageState();
}

class _BetriebAnlegenPageState extends ConsumerState<BetriebAnlegenPage> {
  final _formKey = GlobalKey<FormState>();

  // Textfelder
  final _nameController = TextEditingController();
  final _adresseController = TextEditingController();
  final _plzController = TextEditingController();
  final _ortController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailController = TextEditingController();

  // Auswahl
  int? _selectedBetriebsartId;
  bool _haccpVerantwortlich = true; // Default: ja, Admin ist verantwortlich

  bool _isLoading = false;
  List<Map<String, dynamic>> _betriebsarten = [];

  @override
  void initState() {
    super.initState();
    _loadBetriebsarten();
  }

  Future<void> _loadBetriebsarten() async {
    try {
      final response = await supabase
          .from('betriebsarten')
          .select('id, name')
          .order('name');

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

  Future<void> _saveBetrieb() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('betriebe')
          .insert({
            'name': _nameController.text.trim(),
            'betriebsart_id': _selectedBetriebsartId,
            'adresse': _adresseController.text.trim(),
            'plz': _plzController.text.trim(),
            'ort': _ortController.text.trim(),
            'telefon': _telefonController.text.trim(),
            'email': _emailController.text.trim(),
            'haccp_verantwortlich': _haccpVerantwortlich,
            'sprache': 'de',
            'zeitzone': 'Europe/Berlin',
            'aufbewahrung_jahre': 3,
          })
          .select('id')
          .single();

      final newBetriebId = response['id'] as String;

      // Aktuellen User als Admin zuordnen
      final user = ref.read(authProvider);
      if (user != null) {
        await supabase.from('user_betrieb').insert({
          'user_id': user.id,
          'betrieb_id': newBetriebId,
          'rolle': 'admin',
          'is_favorit': true,
          'last_used': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Betrieb erfolgreich angelegt!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Zurück + neu laden
    } catch (e) {
      print('Fehler beim Speichern: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
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
        title: const Text('Neuen Betrieb anlegen'),
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
                      decoration: const InputDecoration(
                        labelText: 'Betriebsname *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isEmpty ?? true ? 'Pflichtfeld' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      value: _selectedBetriebsartId,
                      decoration: const InputDecoration(
                        labelText: 'Betriebsart *',
                        border: OutlineInputBorder(),
                      ),
                      items: _betriebsarten.map((art) {
                        return DropdownMenuItem<int>(
                          value: art['id'],
                          child: Text(art['name']),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedBetriebsartId = value),
                      validator: (value) => value == null ? 'Pflichtfeld' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _adresseController,
                      decoration: const InputDecoration(
                        labelText: 'Straße & Hausnummer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _plzController,
                            decoration: const InputDecoration(
                              labelText: 'PLZ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ortController,
                            decoration: const InputDecoration(
                              labelText: 'Ort',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _telefonController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-Mail',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    SwitchListTile(
                      title: const Text('HACCP-Verantwortung'),
                      subtitle: const Text('Ist der Admin / Betriebsleiter für HACCP verantwortlich?'),
                      value: _haccpVerantwortlich,
                      onChanged: (value) => setState(() => _haccpVerantwortlich = value),
                      activeColor: Colors.green.shade700,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveBetrieb,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Betrieb speichern', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}