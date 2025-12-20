import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kCreatePurple = Color(0xFF594ABF); // create event
const kFavMaroon   = Color(0xFF9D0D4E); // favorites

// Light Theme
ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: kCreatePurple),
  useMaterial3: true,
  textTheme: GoogleFonts.poppinsTextTheme(),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);

// Dark Theme
ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: kCreatePurple,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  brightness: Brightness.dark,
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);
