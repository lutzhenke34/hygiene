import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: 260,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              Icon(icon,size:48,color:color),

              const SizedBox(height:16),

              Text(
                title,
                style: const TextStyle(fontSize:18),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height:12),

              Text(
                value,
                style: TextStyle(
                  fontSize:36,
                  fontWeight:FontWeight.bold,
                  color:color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}