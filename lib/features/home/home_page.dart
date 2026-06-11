import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlowFinance'), centerTitle: true),
      body: const Center(
        child: Text(
          'Nosso Dashboard vai ficar aqui! 🚀',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
