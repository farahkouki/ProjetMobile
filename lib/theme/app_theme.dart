// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.deepBlue,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.skyBlue),
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.poppinsTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: AppColors.deepBlue),
    elevation: 0,
    titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.deepBlue),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.deepBlue,
  ),
);
