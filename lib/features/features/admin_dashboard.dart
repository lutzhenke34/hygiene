import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final Map<String, dynamic>? betrieb;

  const AdminDashboard({super.key, this.betrieb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(betrieb?['name'] ?? "Dashboard"),
      ),
      body: const Center(
        child: Text("Admin Dashboard läuft"),
      ),
    );
  }
}