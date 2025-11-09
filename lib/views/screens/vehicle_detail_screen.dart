// lib/views/screens/vehicle_detail_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/db_helper.dart';
import '../../models/reservation_model.dart';
import '../../models/vehicle_model.dart';
import '../../controllers/vehicle_controller.dart';
import '../../controllers/driver_controller.dart';

// CORRIGÉ : Import correct
import 'add_edit_vehicle_screen.dart';     // ← Renommé
import 'reservation_form_screen.dart';       // ← OK

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  static const _primary = Color(0xFF0D47A1);
  static const _lightBg = Color(0xFFF5F5F5);
  static const _cardBg = Colors.white;
  static const _border = Color(0xFFE0E0E0);
  static const _textSecondary = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final vc = Provider.of<VehicleController>(context, listen: false);
    final drivers = Provider.of<DriverController>(context).drivers;

    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        title: Text('${vehicle.marque} ${vehicle.modele}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18), overflow: TextOverflow.ellipsis),
        centerTitle: true,
        backgroundColor: _primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditVehicleScreen(vehicle: vehicle))),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _showDeleteDialog(context, vc),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(18), child: _buildImage()),
            const SizedBox(height: 24),

            Text('${vehicle.marque} ${vehicle.modele}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),

            FutureBuilder<List<Reservation>>(
              future: DBHelper().getActiveReservationsByVehicle(vehicle.id!),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                final isFull = count >= 4;
                final canBook = !isFull && drivers.isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(isFull ? Icons.cancel : Icons.check_circle, color: isFull ? Colors.red.shade600 : Colors.green.shade600, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          isFull ? 'Indisponible ($count/4)' : 'Disponible ($count/4)',
                          style: TextStyle(fontWeight: FontWeight.w600, color: isFull ? Colors.red.shade700 : Colors.green.shade700, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _border),
                        boxShadow: [BoxShadow(color: _primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(icon: Icons.directions_car_rounded, label: 'Type', value: vehicle.type),
                          const Divider(height: 28, thickness: 0.8),
                          _buildDetailRow(icon: Icons.event_seat_rounded, label: 'Capacité', value: '${vehicle.capacite} places'),
                          const Divider(height: 28, thickness: 0.8),
                          _buildDetailRow(icon: Icons.monetization_on_rounded, label: 'Prix / jour', value: '${vehicle.prixParJour.toStringAsFixed(2)} DT', valueColor: _primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),



                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: canBook
                            ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReservationFormScreen(vehicle: vehicle)))
                            : null,
                        icon: Icon(canBook ? Icons.book_online : Icons.block, size: 20),
                        label: Text(canBook ? 'Réserver ce véhicule' : isFull ? 'Véhicule complet' : 'Aucun chauffeur'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canBook ? Colors.green.shade600 : Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 8,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (vehicle.image != null && vehicle.image!.isNotEmpty) {
      return kIsWeb
          ? Image.network(vehicle.image!, width: double.infinity, height: 220, fit: BoxFit.cover)
          : Image.file(File(vehicle.image!), width: double.infinity, height: 220, fit: BoxFit.cover);
    } else {
      return Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_rounded, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('Aucune image', style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value, Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: _primary, size: 24),
        const SizedBox(width: 14),
        Text('$label :', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: valueColor ?? Colors.black87), textAlign: TextAlign.end),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, VehicleController vc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
        title: const Text('Supprimer le véhicule ?'),
        content: Text('Voulez-vous vraiment supprimer ${vehicle.marque} ${vehicle.modele} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await vc.deleteVehicle(vehicle.id!);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Véhicule supprimé'), backgroundColor: Colors.red));
      }
    }
  }
}