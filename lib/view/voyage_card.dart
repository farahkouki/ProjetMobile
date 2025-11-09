import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/voyage.dart';
import 'voyage_detail_screen.dart';
import '../database/db_helper.dart';
import 'add_voyage_screen.dart';
import 'reservation_screen.dart';

class VoyageCard extends StatefulWidget {
  final Voyage voyage;
  final VoidCallback onRefresh;

  const VoyageCard({
    super.key,
    required this.voyage,
    required this.onRefresh,
  });

  @override
  State<VoyageCard> createState() => _VoyageCardState();
}

class _VoyageCardState extends State<VoyageCard> {
  // Stocke l'état du favori pour ce voyage
  bool isFavorite = false;

  String _getImageByDestination(String destination) {
    destination = destination.toLowerCase();

    if (destination.contains("paris")) {
      return "https://images.unsplash.com/photo-1502602898657-3e91760cbb34";
    } else if (destination.contains("dubai")) {
      return "https://images.unsplash.com/photo-1512453979798-5ea266f8880c";
    } else if (destination.contains("tunis")) {
      return "https://images.unsplash.com/photo-1546707012-c46675f12716";
    } else if (destination.contains("rome")) {
      return "https://images.unsplash.com/photo-1526481280691-9064e70f7bda";
    } else if (destination.contains("istanbul")) {
      return "https://images.unsplash.com/photo-1588345921523-c2dcdb7f1dcd";
    } else if (destination.contains("london")) {
      return "https://images.unsplash.com/photo-1513635269975-59663e0ac1ad";
    } else if (destination.contains("new york") || destination.contains("newyork")) {
      return "https://images.unsplash.com/photo-1522083165195-3424ed129620";
    } else {
      return "https://images.unsplash.com/photo-1507525428034-b723cf961d3e";
    }
  }

  Color _getContinentColor(String destination) {
    destination = destination.toLowerCase();

    if (destination.contains("tunis") ||
        destination.contains("maroc") ||
        destination.contains("algerie") ||
        destination.contains("egypt") ||
        destination.contains("kenya")) {
      return Colors.green;
    }
    if (destination.contains("paris") ||
        destination.contains("rome") ||
        destination.contains("london") ||
        destination.contains("madrid") ||
        destination.contains("berlin")) {
      return Colors.blue;
    }
    if (destination.contains("dubai") ||
        destination.contains("tokyo") ||
        destination.contains("istanbul") ||
        destination.contains("bali") ||
        destination.contains("doha")) {
      return Colors.red;
    }
    if (destination.contains("new york") ||
        destination.contains("canada") ||
        destination.contains("brazil") ||
        destination.contains("mexico")) {
      return Colors.purple;
    }
    return Colors.orange;
  }

  Future<void> _deleteVoyage(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer ce voyage ?"),
        content: Text("Voulez-vous vraiment supprimer ${widget.voyage.destination} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.instance.deleteVoyage(widget.voyage.id!);
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${widget.voyage.destination} supprimé ✅"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color continentColor = _getContinentColor(widget.voyage.destination);

    return Stack(
      children: [
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      _getImageByDestination(widget.voyage.destination),
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 170,
                          width: double.infinity,
                          color: Colors.blue.shade100,
                          child: const Icon(Icons.flight, size: 60, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  // ❤️ BOUTON FAVORIS
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isFavorite
                                ? "${widget.voyage.destination} ajouté aux favoris ❤️"
                                : "${widget.voyage.destination} retiré des favoris 🤍"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🌍 Destination + point coloré
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: continentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.voyage.destination,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: continentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${DateFormat('dd MMM yyyy', 'fr').format(widget.voyage.dateDepart)} → ${DateFormat('dd MMM yyyy', 'fr').format(widget.voyage.dateArrivee)}',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                        ),
                        Text(
                          '${widget.voyage.budget.toStringAsFixed(0)} TND',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReservationScreen(voyage: widget.voyage),
                                ),
                              );
                            },
                            icon: const Icon(Icons.book_online, size: 20),
                            label: const Text("Réserver maintenant"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: continentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: continentColor, size: 28),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddVoyageScreen(
                                      voyageToEdit: widget.voyage,
                                      onVoyageAdded: widget.onRefresh,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                              onPressed: () => _deleteVoyage(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 🎨 BARRE COLORÉE SUR LE CÔTÉ
        Positioned(
          left: 16,
          top: 10,
          bottom: 10,
          child: Container(
            width: 6,
            decoration: BoxDecoration(
              color: continentColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
