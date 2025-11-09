// lib/controllers/vehicle_controller.dart
import 'package:flutter/foundation.dart';
import '../../core/database/db_helper.dart';
import '../../models/vehicle_model.dart';

class VehicleController with ChangeNotifier {
  List<Vehicle> _vehicles = [];
  List<Vehicle> get vehicles => _vehicles;

  VehicleController() {
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    _vehicles = await DBHelper().getAllVehicles();
    notifyListeners();
  }

  Future<int> addVehicle(Vehicle v) async {
    final id = await DBHelper().insertVehicle(v);
    await loadVehicles();
    return id;
  }

  Future<void> updateVehicle(Vehicle v) async {
    await DBHelper().updateVehicle(v);
    await loadVehicles();
  }

  Future<void> deleteVehicle(int id) async {
    await DBHelper().deleteVehicle(id);
    await loadVehicles();
  }

  Future<bool> isAvailableForPeriod(int vehicleId, DateTime start, DateTime end) async {
    final active = await DBHelper().getActiveReservationsByVehicle(vehicleId);
    if (active.length >= 4) return false;
    for (final r in active) {
      if (start.isBefore(r.endDate) && end.isAfter(r.startDate)) {
        return false;
      }
    }
    return true;
  }

  Vehicle? getVehicleById(int id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  // --- ALERTES DE MAINTENANCE ---
  List<Map<String, dynamic>> getMaintenanceAlerts() {
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (final v in _vehicles) {
      // Révision tous les 5000 km
      final nextServiceKm = ((v.kilometrage / 5000).ceil() * 5000);
      final kmLeft = nextServiceKm - v.kilometrage;
      if (kmLeft <= 500) {
        alerts.add({
          'vehicle': v,
          'type': 'Révision',
          'message': 'Révision à $nextServiceKm km ($kmLeft km restants)',
          'urgent': kmLeft <= 200,
        });
      }

      // Vidange tous les 6 mois
      final nextOilChange = v.derniereVidange.add(const Duration(days: 180));
      final daysUntil = nextOilChange.difference(now).inDays;
      if (daysUntil <= 30) {
        alerts.add({
          'vehicle': v,
          'type': 'Vidange',
          'message': 'Vidange dans $daysUntil jours',
          'urgent': daysUntil <= 7,
        });
      }
    }

    return alerts;
  }

  Future<void> logMaintenance(int vehicleId, String type, int km) async {
    final now = DateTime.now();
    await DBHelper().insertMaintenance(vehicleId, type, now.millisecondsSinceEpoch, km);

    final db = await DBHelper().database;

    if (type == 'Vidange') {
      // Met à jour km + date vidange
      await db.update(
        'vehicles',
        {
          'kilometrage': km,
          'derniereVidange': now.millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [vehicleId],
      );
    } else {
      // Met à jour seulement le km
      await db.update(
        'vehicles',
        {'kilometrage': km},
        where: 'id = ?',
        whereArgs: [vehicleId],
      );
    }

    await loadVehicles();
  }
}