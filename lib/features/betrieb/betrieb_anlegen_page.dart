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
import '../../../providers/auth_provider.dart';



class BetriebAnlegenPage extends ConsumerStatefulWidget {
  const BetriebAnlegenPage({super.key});

  @override
  ConsumerState<BetriebAnlegenPage> createState() => _BetriebAnlegenPageState();
}

class _BetriebAnlegenPageState extends ConsumerState<BetriebAnlegenPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _adresseController = TextEditingController();
  final _plzController = TextEditingController();
  final _ortController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailController = TextEditingController();
  final _sonstigesController = TextEditingController();

  int? _selectedHauptkategorieId;
  int? _selectedUnterkategorieId;
  bool _haccpVerantwortlich = true;
  bool _showSonstigesFreitext = false;

  bool _isLoading = false;

  List<Map<String, dynamic>> _hauptkategorien = [];
  List<Map<String, dynamic>> _unterkategorien = [];

  @override
  void initState() {
    super.initState();
    _loadHauptkategorien();
  }

  Future<void> _loadHauptkategorien() async {
    try {
      final res = await supabase
          .from('betriebsarten')
          .select('id, name')
          .order('name');

      setState(() {
        _hauptkategorien = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      print('Fehler beim Laden der Hauptkategorien: $e');
    }
  }

  Future<void> _loadUnterkategorien(int? hauptkategorieId) async {
    if (hauptkategorieId == null) {
      setState(() {
        _unterkategorien = [];
        _selectedUnterkategorieId = null;
        _showSonstigesFreitext = false;
      });
      return;
    }

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
      print('Fehler beim Laden der Unterkategorien: $e');
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
            'betriebsart_id': _selectedHauptkategorieId,
            'betriebsunterkategorie_id': _selectedUnterkategorieId,
            'sonstiges': _showSonstigesFreitext ? _sonstigesController.text.trim() : null,
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

      // Verknüpfung mit User
      final user = ref.read(authProvider);
      if (user != null) {
        await supabase.from('user_betrieb').insert({
          'user_id': user.id,
          'betrieb_id': newBetriebId,
          'rolle': 'admin',
          'is_favorit': true,
          'last_used': DateTime.now().toIso8601String(),
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_betrieb_id', newBetriebId);
        await prefs.setString('selected_betrieb_name', _nameController.text.trim());

        await ref.read(selectedBetriebIdProvider.notifier).set(newBetriebId);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminDashboardPage(),
        ),
      );
    } catch (e) {
      print('Fehler beim Anlegen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Anlegen: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Betrieb anlegen'),
        backgroundColor: Colors.green,
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
                      validator: (v) => v!.trim().isEmpty ? 'Pflichtfeld' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      value: _selectedHauptkategorieId,
                      decoration: const InputDecoration(labelText: 'Hauptkategorie'),
                      items: _hauptkategorien.map((e) {
                        return DropdownMenuItem<int>(
                          value: e['id'],
                          child: Text(e['name']),
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
                        value: _selectedUnterkategorieId,
                        decoration: const InputDecoration(labelText: 'Unterkategorie'),
                        items: [
                          ..._unterkategorien.map((e) => DropdownMenuItem<int>(
                                value: e['id'],
                                child: Text(e['name']),
                              )),
                          const DropdownMenuItem<int>(
                            value: 0,
                            child: Text('Sonstiges (Freitext)'),
                          ),
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

                    TextFormField(
                      controller: _adresseController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _plzController,
                      decoration: const InputDecoration(labelText: 'PLZ'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _ortController,
                      decoration: const InputDecoration(labelText: 'Ort'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _telefonController,
                      decoration: const InputDecoration(labelText: 'Telefon'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    SwitchListTile(
                      title: const Text('HACCP-Verantwortlich'),
                      value: _haccpVerantwortlich,
                      onChanged: (v) => setState(() => _haccpVerantwortlich = v),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _saveBetrieb,
                      child: const Text('Betrieb anlegen'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}