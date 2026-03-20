import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://fihpnrujwjrpblzczyiq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpaHBucnVqd2pycGJsemN6eWlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MzI3ODQsImV4cCI6MjA4NjMwODc4NH0.vSCSs4DbsUJw5nFKpaQOymgsLxlvJsx1YnTakeNQMh4',
  );
}

final supabase = Supabase.instance.client;