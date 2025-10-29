import 'package:flutter/material.dart';

class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promoções')),
      body: const Center(
        child: Text('Confira nossas ofertas especiais!'),
      ),
    );
  }
}