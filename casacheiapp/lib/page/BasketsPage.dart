import 'package:flutter/material.dart';

class BasketsPage extends StatelessWidget {
  const BasketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nossas Cestas')),
      body: const Center(
        child: Text('Aqui você encontrará todas as nossas cestas.'),
      ),
    );
  }
}