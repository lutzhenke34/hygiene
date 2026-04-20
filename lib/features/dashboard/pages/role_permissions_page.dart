import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/role_permission_provider.dart';   // ← KORRIGIERT: nur "../providers/"
import '../models/role_permission.dart';

class RolePermissionsPage extends ConsumerStatefulWidget {
  final String betriebId;

  const RolePermissionsPage({super.key, required this.betriebId});

  @override
  ConsumerState<RolePermissionsPage> createState() => _RolePermissionsPageState();
}

class _RolePermissionsPageState extends ConsumerState<RolePermissionsPage> {
  List<String> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final data = await Supabase.instance.client
          .from('role_permissions')
          .select('role_name')
          .eq('betrieb_id', widget.betriebId);

      final roles = data.map((e) => e['role_name'] as String).toList();
      setState(() {
        _roles = roles.isNotEmpty ? roles : ['admin', 'betriebsleiter', 'kuechenchef', 'teamleiter', 'service', 'mitarbeiter'];
      });
    } catch (e) {
      print('Fehler beim Laden der Rollen: $e');
      setState(() {
        _roles = ['admin', 'betriebsleiter', 'kuechenchef', 'teamleiter', 'service', 'mitarbeiter'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rollen & Berechtigungen'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: _roles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                final permissionAsync = ref.watch(rolePermissionNotifierProvider(widget.betriebId, role));

                return permissionAsync.when(
                  loading: () => const ListTile(title: Text('Lädt...')),
                  error: (e, _) => ListTile(
                    title: Text(role),
                    subtitle: Text('Fehler: $e'),
                  ),
                  data: (permission) {
                    if (permission == null) {
                      return ListTile(
                        title: Text(role),
                        subtitle: const Text('Keine Berechtigungen gefunden'),
                        trailing: const Icon(Icons.warning, color: Colors.orange),
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(
                          role.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          SwitchListTile(
                            title: const Text('Mitarbeiter verwalten'),
                            value: permission.canManageMitarbeiter,
                            onChanged: (val) => _updatePermission(role, 'can_manage_mitarbeiter', val),
                          ),
                          SwitchListTile(
                            title: const Text('Geräte verwalten'),
                            value: permission.canManageGeraete,
                            onChanged: (val) => _updatePermission(role, 'can_manage_geraete', val),
                          ),
                          SwitchListTile(
                            title: const Text('Kühlgeräte verwalten'),
                            value: permission.canManageKuehlgeraete,
                            onChanged: (val) => _updatePermission(role, 'can_manage_kuehlgeraete', val),
                          ),
                          SwitchListTile(
                            title: const Text('Hygieneaufgaben erstellen'),
                            value: permission.canCreateHygieneAufgaben,
                            onChanged: (val) => _updatePermission(role, 'can_create_hygiene_aufgaben', val),
                          ),
                          SwitchListTile(
                            title: const Text('Aufgaben erstellen'),
                            value: permission.canCreateAufgaben,
                            onChanged: (val) => _updatePermission(role, 'can_create_aufgaben', val),
                          ),
                          SwitchListTile(
                            title: const Text('Schichten verwalten'),
                            value: permission.canManageSchichten,
                            onChanged: (val) => _updatePermission(role, 'can_manage_schichten', val),
                          ),
                          SwitchListTile(
                            title: const Text('Alle Protokolle sehen'),
                            value: permission.canSeeAllProtokolle,
                            onChanged: (val) => _updatePermission(role, 'can_see_all_protokolle', val),
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

  Future<void> _updatePermission(String role, String field, bool value) async {
    try {
      await Supabase.instance.client
          .from('role_permissions')
          .update({field: value})
          .eq('betrieb_id', widget.betriebId)
          .eq('role_name', role);

      ref.invalidate(rolePermissionNotifierProvider(widget.betriebId, role));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ $role aktualisiert')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }
}