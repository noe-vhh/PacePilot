// theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color.fromRGBO(153, 189, 156, 1);
  static const Color secondaryColor = Color.fromRGBO(89, 114, 111, 1);
  static const Color textColor = Color.fromRGBO(104, 108, 107, 1);

  // Box Shadow
  static const BoxShadow defaultBoxShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.25),
    offset: Offset(0, 4),
    blurRadius: 4,
  );

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Sansation',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Sansation',
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16.0,
    color: textColor,
    fontFamily: 'Sansation',
    height: 1.5,
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 20.0,
    color: Colors.white,
    fontFamily: 'Sansation',
  );

  // Button and Input Decoration Themes
  static final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );

  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    fillColor: Colors.white,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    hintStyle: const TextStyle(
      color: Colors.grey,
    ),
  );

  // Gradient for Background
  static LinearGradient get backgroundGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(228, 228, 228, 1)],
    );
  }

  // Complete ThemeData for the App
  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: buildTextTheme(),
      elevatedButtonTheme: elevatedButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
    );
  }

  // Building Text Theme
  static TextTheme buildTextTheme() {
    return const TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      bodyLarge: bodyText,
      labelLarge: labelText,
    );
  }
}