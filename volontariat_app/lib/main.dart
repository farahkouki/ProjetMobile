import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'screens/volunteer_list_screen.dart';
import 'screens/volunteer_form_screen.dart';
import 'screens/country_list_screen.dart';
import 'screens/search_ai_screen.dart';
import 'screens/volunteer_detail_screen.dart';
import 'models/volunteer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // IMPORTANT Web : sqflite en mode sans worker (évite sqflite_sw.js en dev)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }

  runApp(const VolontariatApp());
}

class VolontariatApp extends StatelessWidget {
  const VolontariatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volontariat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2B74FF)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: UnderlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),

      // 👉 NE PAS enregistrer ici les écrans qui ont des arguments requis
      routes: {
        '/': (_) => const VolunteerListScreen(),
        CountryListScreen.routeName: (_) => const CountryListScreen(),
        SearchAIScreen.routeName: (_) => const SearchAIScreen(),
        // VolunteerFormScreen et VolunteerDetailScreen sont gérés plus bas
      },

      // 👉 Construit dynamiquement les écrans avec leurs arguments
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case VolunteerFormScreen.routeName:
          // argument optionnel: Volunteer (édition) ou null (création)
            final arg = settings.arguments;
            final editing = (arg is Volunteer) ? arg : null;
            return MaterialPageRoute(
              builder: (_) => VolunteerFormScreen(editing: editing),
            );

          case VolunteerDetailScreen.routeName:
          // argument requis: int (ID du volontariat)
            final arg = settings.arguments;
            final int? id = (arg is int) ? arg : null;
            if (id == null) {
              // Sécurise en cas d'appel sans argument
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Aucun ID de volontariat fourni')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => VolunteerDetailScreen(volunteerId: id),
            );
        }
        return null;
      },
    );
  }
}
