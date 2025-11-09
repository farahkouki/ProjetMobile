import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image fixe pour ne pas dépasser
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: vehicle.image != null
                    ? kIsWeb
                    ? Image.network(vehicle.image!, fit: BoxFit.cover)
                    : Image.file(File(vehicle.image!), fit: BoxFit.cover)
                    : Icon(Icons.directions_car, size: 48, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              // Texte flexible pour éviter overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.marque} ${vehicle.modele}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('Type: ${vehicle.type}'),
                    const SizedBox(height: 4),
                    Text('Capacité: ${vehicle.capacite} places'),
                    const SizedBox(height: 4),
                    Text('Prix: ${vehicle.prixParJour.toStringAsFixed(2)} DT / jour'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          vehicle.disponibilite == 1 ? Icons.check_circle : Icons.remove_circle,
                          color: vehicle.disponibilite == 1 ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(vehicle.disponibilite == 1 ? 'Disponible' : 'Indisponible'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
