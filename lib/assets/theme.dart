// theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Define a static method to get the background gradient
  static LinearGradient get backgroundGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color.fromRGBO(104, 108, 107, 1), Color.fromRGBO(64, 64, 64, 1)],
    );
  }

  // Define a static method to get the overall theme data for the application
  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: buildTextTheme(), // Utilize the defined text theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(153, 189, 156, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  // Define a static method to build the text theme for the application
  static TextTheme buildTextTheme() {
    return const TextTheme(
      // Large display text style
      displayLarge: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'Sansation',
      ),
      // Medium display text style
      displayMedium: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'Sansation',
      ),
      // Large body text style
      bodyLarge: TextStyle(
        fontSize: 15.0,
        color: Colors.white,
        fontFamily: 'Sansation',
      ),
      // Large label text style
      labelLarge: TextStyle(
        fontSize: 20.0,
        color: Colors.white,
        fontFamily: 'Sansation',
      ),
    );
  }
}