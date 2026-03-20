import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Kacheln oben
            Row(
              children: [
                Expanded(
                  child: _DashboardTile(
                    title: 'Mitarbeiter',
                    icon: Icons.people,
                    onTap: () {
                      print('Mitarbeiter öffnen');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardTile(
                    title: 'Hygiene',
                    icon: Icons.cleaning_services,
                    onTap: () {
                      print('Hygiene öffnen');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardTile(
                    title: 'Aufgaben',
                    icon: Icons.check_circle,
                    onTap: () {
                      print('Aufgaben öffnen');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 HACCP Balken
            GestureDetector(
              onTap: () {
                print('HACCP öffnen');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'HACCP Protokolle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}