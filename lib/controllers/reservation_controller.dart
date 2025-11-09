// lib/controllers/reservation_controller.dart
import 'package:flutter/foundation.dart';
import '../../core/database/db_helper.dart';
import '../../models/reservation_model.dart';
import 'vehicle_controller.dart';

class ReservationController with ChangeNotifier {
  List<Reservation> _reservations = [];
  List<Reservation> get reservations => _reservations;

  ReservationController() {
    loadReservations();
  }

  Future<void> loadReservations() async {
    _reservations = await DBHelper().getAllReservations();
    notifyListeners();
  }

  Future<String?> addReservation(Reservation r, VehicleController vc) async {
    final canBook = await vc.isAvailableForPeriod(r.vehicleId, r.startDate, r.endDate);
    if (!canBook) {
      return "Ce véhicule est déjà réservé à cette période ou a atteint sa capacité maximale (4).";
    }
    await DBHelper().insertReservation(r);
    await loadReservations();
    return null;
  }

  Future<void> updateStatus(int id, String status) async {
    await DBHelper().updateReservationStatus(id, status);
    await loadReservations();
  }

  List<Reservation> getReservationsByDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _reservations.where((r) {
      final start = DateTime(r.startDate.year, r.startDate.month, r.startDate.day);
      final end = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
      return day.isAtSameMomentAs(start) ||
          day.isAtSameMomentAs(end) ||
          (day.isAfter(start) && day.isBefore(end));
    }).toList();
  }

  Future<void> cancelReservation(int id) async {
    await DBHelper().deleteReservation(id);
    await loadReservations();
  }
}