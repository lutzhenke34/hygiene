import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final rollenProvider = FutureProvider<List<String>>((ref) async {
  final response = await Supabase.instance.client
      .from('rollen')
      .select('name')
      .order('name');

  final rollen = response
      .map((row) => row['name']?.toString().trim() ?? '')
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  return rollen;
});
