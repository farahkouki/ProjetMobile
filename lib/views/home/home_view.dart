import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voyagea — Agence de Voyage"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Bienvenue sur Voyagea 🚐",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
