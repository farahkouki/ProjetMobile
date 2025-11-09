// lib/controllers/driver_controller.dart
import 'package:flutter/foundation.dart'; // ChangeNotifier
import '../core/database/db_helper.dart';
import '../models/driver_model.dart';

class DriverController extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<Driver> _drivers = [];
  bool _loading = false;

  // Getters
  List<Driver> get drivers => _drivers;
  bool get loading => _loading;

  DriverController() {
    refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();

    _drivers = await _db.getAllDrivers();

    _loading = false;
    notifyListeners();
  }

  Future<void> addDriver(Driver d) async {
    await _db.insertDriver(d);
    await refresh();
  }

  Future<void> updateDriver(Driver d) async {
    await _db.updateDriver(d);
    await refresh();
  }

  Future<void> deleteDriver(int id) async {
    await _db.deleteDriver(id);
    await refresh();
  }

  // AJOUTÉ : Récupérer un chauffeur par ID
  Driver? getDriverById(int id) {
    try {
      return _drivers.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}