import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/role_permission.dart';

part 'role_permission_provider.g.dart';

final supabase = Supabase.instance.client;

@riverpod
class RolePermissionNotifier extends _$RolePermissionNotifier {
  @override
  Future<RolePermission?> build(String betriebId, String roleName) async {
    try {
      final data = await supabase
          .from('role_permissions')
          .select()
          .eq('betrieb_id', betriebId)
          .eq('role_name', roleName)
          .maybeSingle();

      if (data == null) return null;
      return RolePermission.fromJson(data);
    } catch (e) {
      print('Fehler beim Laden der Berechtigungen: $e');
      return null;
    }
  }
}