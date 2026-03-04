import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard/admin_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fihpnrujwjrpblzczyiq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpaHBucnVqd2pycGJsemN6eWlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MzI3ODQsImV4cCI6MjA4NjMwODc4NH0.vSCSs4DbsUJw5nFKpaQOymgsLxlvJsx1YnTakeNQMh4', // ← deinen vollen Key!
  );

  runApp(
    ProviderScope(  // const entfernt – das löst den ThemeData-Fehler
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hygiene App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AdminDashboard(),
      ),
    ),
  );
}