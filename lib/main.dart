// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'features/admin/home/admin_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable FFI for desktop (Windows, Linux, macOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agence (Admin)',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const AdminHomePage(),
    );
  }
}
