// lib/views/screens/planning_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/reservation_model.dart';
import '../../models/vehicle_model.dart';
import '../../models/driver_model.dart';
import '../../controllers/reservation_controller.dart';
import '../../controllers/vehicle_controller.dart';
import '../../controllers/driver_controller.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  // Palette cohérente
  static const _primary = Color(0xFF0D47A1);
  static const _lightBg = Color(0xFFF5F5F5);
  static const _cardBg = Colors.white;
  static const _border = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      Provider.of<ReservationController>(context, listen: false).loadReservations(),
      Provider.of<VehicleController>(context, listen: false).loadVehicles(),
      Provider.of<DriverController>(context, listen: false).refresh(),
    ]);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final rc = Provider.of<ReservationController>(context);
    final vc = Provider.of<VehicleController>(context);
    final dc = Provider.of<DriverController>(context);

    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        title: const Text('Planning', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: _primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: _primary,
        child: _isLoading
            ? _buildShimmer()
            : Column(
          children: [
            // CALENDRIER
            _buildCalendar(rc),
            const SizedBox(height: 16),

            // LISTE DES RÉSERVATIONS (AFFICHAGE SEULEMENT)
            Expanded(child: _buildReservationList(rc, vc, dc)),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // CALENDRIER
  // -------------------------------------------------
  Widget _buildCalendar(ReservationController rc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: _primary.withOpacity(0.3), shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: _primary, shape: BoxShape.circle),
          markerDecoration: BoxDecoration(color: Colors.green.shade600, shape: BoxShape.circle),
        ),
        eventLoader: (day) {
          final reservations = rc.getReservationsByDate(day);
          return reservations.isNotEmpty ? [reservations.length] : [];
        },
      ),
    );
  }

  // -------------------------------------------------
  // LISTE DES RÉSERVATIONS – AFFICHAGE SEULEMENT
  // -------------------------------------------------
  Widget _buildReservationList(ReservationController rc, VehicleController vc, DriverController dc) {
    final selectedDate = _selectedDay ?? DateTime.now();
    final reservations = rc.getReservationsByDate(selectedDate);

    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Aucune réservation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Sélectionnez une date', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: reservations.length,
      itemBuilder: (ctx, i) {
        final r = reservations[i];
        final vehicle = vc.getVehicleById(r.vehicleId);
        final driver = dc.getDriverById(r.driverId);

        return FadeInUp(
          duration: Duration(milliseconds: 300 + (i * 80)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: [BoxShadow(color: _primary.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_car, color: _primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      vehicle?.marque ?? 'Inconnu',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '${r.startDate.day}/${r.startDate.month} → ${r.endDate.day}/${r.endDate.month}',
                        style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Client: ${r.clientName}', style: const TextStyle(fontSize: 14)),
                Text('Chauffeur: ${driver?.nom ?? 'Inconnu'}', style: const TextStyle(fontSize: 14)),
                Text('Total: ${r.totalPrice.toStringAsFixed(2)} DT', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primary)),
                // BOUTONS SUPPRIMÉS
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------
  // SHIMMER
  // -------------------------------------------------
  Widget _buildShimmer() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (_, i) => Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}