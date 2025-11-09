import 'package:flutter/material.dart';
import '../models/voyage.dart';

class ReservationScreen extends StatelessWidget {
  final Voyage voyage;

  const ReservationScreen({super.key, required this.voyage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réserver un voyage"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Voyage sélectionné :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Destination : ${voyage.destination}", style: const TextStyle(fontSize: 16)),
                    Text("Budget : ${voyage.budget} TND"),
                    Text("Départ : ${voyage.dateDepart}"),
                    Text("Retour : ${voyage.dateArrivee}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Formulaire de réservation bientôt ici...",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Réservation enregistrée ✅")),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Confirmer la réservation",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
