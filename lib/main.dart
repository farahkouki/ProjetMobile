// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/vehicle_controller.dart';
import 'controllers/driver_controller.dart';
import 'controllers/reservation_controller.dart';
import 'theme/app_theme.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/planning_screen.dart'; // ← AJOUTÉ

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoyageaApp());
}

class VoyageaApp extends StatelessWidget {
  const VoyageaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VehicleController()),
        ChangeNotifierProvider(create: (_) => DriverController()),
        ChangeNotifierProvider(create: (_) => ReservationController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Voyagea',
        theme: appTheme,
        home: const HomeScreen(),

        // AJOUT : Route pour le planning
        routes: {
          '/planning': (context) => const PlanningScreen(),
        },
      ),
    );
  }
}