// lib/view/voyages_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/voyage.dart';
import '../database/db_helper.dart';
import 'add_voyage_screen.dart';
import 'voyage_card.dart';

class VoyagesScreen extends StatefulWidget {
  const VoyagesScreen({super.key});

  @override
  State<VoyagesScreen> createState() => _VoyagesScreenState();
}

class _VoyagesScreenState extends State<VoyagesScreen> {
  final DBHelper db = DBHelper.instance;
  List<Voyage> voyages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVoyages();
  }

  Future<void> _loadVoyages() async {
    setState(() => isLoading = true);
    final data = await db.getAllVoyages();
    setState(() {
      voyages = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Mes Voyages",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 6,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVoyages,
            tooltip: "Actualiser",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : voyages.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadVoyages,
        color: Colors.indigo,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          itemCount: voyages.length,
          itemBuilder: (context, index) {
            final voyage = voyages[index];

            return Dismissible(
              key: Key(voyage.uuid),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 30),
                child: const Icon(Icons.delete_forever, color: Colors.white, size: 40),
              ),
              confirmDismiss: (_) async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text("Supprimer ce voyage ?"),
                    content: Text("Voulez-vous vraiment supprimer ${voyage.destination} ?"),
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
                  await db.deleteVoyage(voyage.id!);
                  _loadVoyages();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${voyage.destination} supprimé !"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  return true;
                }
                return false;
              },
              child: VoyageCard(
                voyage: voyage,
                onRefresh: _loadVoyages, // Rafraîchit après modif ou suppression
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVoyageScreen()),
          );
          if (result == true) _loadVoyages();
        },
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nouveau voyage",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff, size: 120, color: Colors.grey[400]),
          const SizedBox(height: 30),
          Text(
            "Aucun voyage pour le moment",
            style: TextStyle(fontSize: 24, color: Colors.grey[700], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            "Appuyez sur + pour planifier votre prochaine aventure",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}