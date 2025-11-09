// lib/views/screens/vehicle_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';

import '../../core/database/db_helper.dart';
import '../../models/reservation_model.dart';
import '../../controllers/vehicle_controller.dart';
import '../widgets/vehicle_card.dart';

// CORRIGÉ : Import du bon écran
import 'add_edit_vehicle_screen.dart';     // ← Renommé
import 'vehicle_detail_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  String _searchQuery = '';
  bool _isLoading = true;

  // -------------------------------------------------
  // Palette cohérente
  // -------------------------------------------------
  static const _primary = Color(0xFF0D47A1);
  static const _lightGray = Color(0xFFF5F5F5);
  static const _cardBg = Colors.white;
  static const _border = Color(0xFFE0E0E0);
  static const _textSecondary = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Provider.of<VehicleController>(context, listen: false).loadVehicles();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final vc = Provider.of<VehicleController>(context);
    final filteredVehicles = vc.vehicles.where((v) {
      final query = _searchQuery.toLowerCase();
      return v.marque.toLowerCase().contains(query) ||
          v.modele.toLowerCase().contains(query) ||
          v.type.toLowerCase().contains(query) ||
          v.capacite.toString().contains(query) ||
          v.prixParJour.toString().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        title: const Text(
          'Véhicules',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: _primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          // -------------------------------------------------
          // Barre de recherche
          // -------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Container(
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: _primary.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un véhicule...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: _primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),

          // -------------------------------------------------
          // Liste des véhicules
          // -------------------------------------------------
          Expanded(
            child: _isLoading
                ? _buildShimmerList()
                : filteredVehicles.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadData,
              color: _primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8).copyWith(bottom: 90),
                itemCount: filteredVehicles.length,
                itemBuilder: (ctx, i) {
                  final v = filteredVehicles[i];
                  return FadeInUp(
                    duration: Duration(milliseconds: 300 + (i * 80)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          // CORRIGÉ : Navigation vers le détail
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: v)),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _cardBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: _border),
                              boxShadow: [
                                BoxShadow(color: _primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: FutureBuilder<List<Reservation>>(
                              future: DBHelper().getActiveReservationsByVehicle(v.id!),
                              builder: (context, snapshot) {
                                final count = snapshot.data?.length ?? 0;
                                final isFull = count >= 4;
                                return Stack(
                                  children: [
                                    VehicleCard(vehicle: v),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isFull ? Colors.red.shade100 : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isFull ? Icons.block : Icons.event_available,
                                              size: 14,
                                              color: isFull ? Colors.red : Colors.orange,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$count/4',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isFull ? Colors.red : Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // -------------------------------------------------
      // FAB – Ajouter un véhicule
      // -------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        // CORRIGÉ : Écran d'ajout
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditVehicleScreen()),
        ),
        backgroundColor: _primary,
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // -------------------------------------------------
  // État vide
  // -------------------------------------------------
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'Aucun véhicule trouvé',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textSecondary),
        ),
        const SizedBox(height: 8),
        Text('Essayez de modifier votre recherche', style: TextStyle(color: Colors.grey.shade500)),
      ],
    ),
  );

  // -------------------------------------------------
  // Shimmer loading
  // -------------------------------------------------
  Widget _buildShimmerList() => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    itemCount: 6,
    itemBuilder: (context, index) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
        ),
      ),
    ),
  );

}