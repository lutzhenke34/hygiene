import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../dashboard/admin_dashboard.dart';

class BetriebSelectPage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const BetriebSelectPage({super.key, required this.profile});

  @override
  State<BetriebSelectPage> createState() => _BetriebSelectPageState();
}

class _BetriebSelectPageState extends State<BetriebSelectPage> {
  List<Map<String, dynamic>> betriebe = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await Supabase.instance.client
        .from('betriebe')
        .select();

    setState(() {
      betriebe = List<Map<String, dynamic>>.from(data);
    });
  }

  void select(Map<String, dynamic> b) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboard(betrieb: b),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Betrieb wählen")),
      body: ListView(
        children: betriebe.map((b) {
          return ListTile(
            title: Text(b['name']),
            onTap: () => select(b),
          );
        }).toList(),
      ),
    );
  }
}