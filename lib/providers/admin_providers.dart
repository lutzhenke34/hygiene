import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_providers.g.dart';

// ==================== MITARBEITER PROVIDER ====================

@riverpod
Future<List<Map<String, dynamic>>> mitarbeiter(
  MitarbeiterRef ref,
  String betriebId,
) async {
  if (betriebId.isEmpty) return [];

  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('mitarbeiter')
      .select()
      .eq('betrieb_id', betriebId);

  return List<Map<String, dynamic>>.from(response);
}