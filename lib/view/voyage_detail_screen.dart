// lib/view/voyage_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/voyage.dart';
import '../services/pdf_generator.dart';

class VoyageDetailScreen extends StatelessWidget {
  final Voyage voyage; // ON REÇOIT DIRECTEMENT L'OBJET VOYAGE
  const VoyageDetailScreen({super.key, required this.voyage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(voyage.destination),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte résumé
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow("Destination", voyage.destination, icon: Icons.location_on),
                    const Divider(),
                    _buildRow("Départ", DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(voyage.dateDepart)),
                    _buildRow("Retour", DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(voyage.dateArrivee)),
                    const Divider(),
                    _buildRow("Budget", "${voyage.budget.toStringAsFixed(0)} TND", icon: Icons.paid),
                    if (voyage.description.isNotEmpty) ...[
                      const Divider(),
                      _buildRow("Notes", voyage.description, icon: Icons.note),
                    ],
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Bouton PDF
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf, size: 28),
                label: const Text("Ouvrir le billet PDF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                ),
                onPressed: () => PdfGenerator.generatePdf(voyage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, color: Colors.indigo, size: 28),
          if (icon != null) const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}