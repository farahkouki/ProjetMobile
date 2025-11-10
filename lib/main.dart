import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'pages/signin_page.dart';
import 'pages/signup_page.dart';
import 'pages/offers_page.dart';
import 'pages/profile_page.dart';
import 'pages/reset_password_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  await AuthService().initialize();
  runApp(TravelApp());
}

class TravelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in
    bool isLoggedIn = AuthService().isLoggedIn;
    
    return MaterialApp(
      title: 'Travel Agency',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // Initial route: if logged in → offers, else → signin
      initialRoute: isLoggedIn ? '/offers' : '/signin',
      
      // Routes
      routes: {
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/offers': (context) => OffersPage(),
        '/profile': (context) => ProfilePage(),
        '/reset-password': (context) => const ResetPasswordPage(), // ← add this

      },
    );
  }
}