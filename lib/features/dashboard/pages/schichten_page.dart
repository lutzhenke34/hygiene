import 'package:flutter/material.dart';

class SchichtenPage extends StatelessWidget {
  const SchichtenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schichten'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Schichten einrichten')),
    );
  }
}