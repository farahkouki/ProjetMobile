// lib/views/screens/maintenance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../models/vehicle_model.dart';
import '../../controllers/vehicle_controller.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<VehicleController>(context, listen: false).loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    final vc = Provider.of<VehicleController>(context);
    final alerts = vc.getMaintenanceAlerts();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Maintenance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: alerts.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (ctx, i) => FadeInUp(
          duration: Duration(milliseconds: 300 + (i * 80)),
          child: _alertCard(alerts[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add),
        onPressed: () => _showLogDialog(context, vc),
      ),
    );
  }

  Widget _alertCard(Map<String, dynamic> alert) {
    final Vehicle v = alert['vehicle'];
    final bool urgent = alert['urgent'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: urgent ? Colors.red.shade200 : const Color(0xFFE0E0E0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: urgent ? Colors.red.shade100 : const Color(0xFF0D47A1).withOpacity(0.1),
            child: Icon(
              alert['type'] == 'Révision' ? Icons.build : Icons.oil_barrel,
              color: urgent ? Colors.red : const Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${v.marque} ${v.modele}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(alert['message'], style: TextStyle(color: urgent ? Colors.red : Colors.grey.shade700)),
              ],
            ),
          ),
          if (urgent)
            const Text('URGENT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 70, color: Colors.green.shade400),
          const SizedBox(height: 16),
          const Text('Tout est à jour !', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showLogDialog(BuildContext context, VehicleController vc) {
    final controller = TextEditingController();
    Vehicle? selectedVehicle = vc.vehicles.firstOrNull;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Enregistrer maintenance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedVehicle?.id,
                decoration: const InputDecoration(labelText: 'Véhicule'),
                items: vc.vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text('${v.marque} ${v.modele}'))).toList(),
                onChanged: (id) => setStateDialog(() => selectedVehicle = vc.getVehicleById(id!)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kilométrage actuel'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: 'Révision',
                decoration: const InputDecoration(labelText: 'Type'),
                items: ['Révision', 'Vidange'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (_) {},
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                final km = int.tryParse(controller.text) ?? 0;
                final type = 'Révision'; // À améliorer
                if (selectedVehicle != null) {
                  await vc.logMaintenance(selectedVehicle!.id!, type, km);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Maintenance enregistrée'), backgroundColor: Colors.green),
                  );
                }
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}