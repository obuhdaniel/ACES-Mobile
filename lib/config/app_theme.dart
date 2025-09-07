// App Theme
import 'package:flutter/material.dart';

class AppTheme {
  // Updated Colors
  static const Color primaryTeal = Color(0xFF166D86); // Primary color
  static const Color textColor = Color(0xFF2F327D);   // Text color
  static const Color lightGreen = Color(0xFFB2FFB2);  // Green color
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2A2A2A);
    static const Color lightTeal = Color(0xFFE0F7FA);
  static const Color cardBackground = Color(0xFFFAFAFA);
  static const Color accentOrange = Color(0xFFFF7043);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentGreen = Color(0xFF4CAF50);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: const MaterialColor(0xFF166D86, {
      50: Color(0xFFE6F3F6),
      100: Color(0xFFB3DCE4),
      200: Color(0xFF80C5D2),
      300: Color(0xFF4DAEC0),
      400: Color(0xFF339FB5),
      500: Color(0xFF166D86),
      600: Color(0xFF145F76),
      700: Color(0xFF114F62),
      800: Color(0xFF0E3F4F),
      900: Color(0xFF0A2C38),
    }),
    scaffoldBackgroundColor: lightBackground,
    cardColor: cardLight,
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      secondary: lightGreen,
      surface: cardLight,
      background: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textColor,
      onBackground: textColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: textColor),
      titleLarge: TextStyle(color: textColor),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
  );

  // static ThemeData darkTheme = ThemeData(
  //   useMaterial3: true,
  //   brightness: Brightness.dark,
  //   primarySwatch: const MaterialColor(0xFF166D86, {
  //     50: Color(0xFFE6F3F6),
  //     100: Color(0xFFB3DCE4),
  //     200: Color(0xFF80C5D2),
  //     300: Color(0xFF4DAEC0),
  //     400: Color(0xFF339FB5),
  //     500: Color(0xFF166D86),
  //     600: Color(0xFF145F76),
  //     700: Color(0xFF114F62),
  //     800: Color(0xFF0E3F4F),
  //     900: Color(0xFF0A2C38),
  //   }),
  //   scaffoldBackgroundColor: darkBackground,
  //   cardColor: cardDark,
  //   colorScheme: const ColorScheme.dark(
  //     primary: primaryTeal,
  //     secondary: lightGreen,
  //     surface: cardDark,
  //     background: darkBackground,
  //     onPrimary: Colors.white,
  //     onSecondary: Colors.black,
  //     onSurface: Colors.white,
  //     onBackground: Colors.white,
  //   ),
  //   textTheme: const TextTheme(
  //     bodyLarge: TextStyle(color: Colors.white),
  //     bodyMedium: TextStyle(color: Colors.white70),
  //     bodySmall: TextStyle(color: Colors.white60),
  //     titleLarge: TextStyle(color: Colors.white),
  //   ),
  //   appBarTheme: const AppBarTheme(
  //     backgroundColor: darkBackground,
  //     foregroundColor: Colors.white,
  //     elevation: 0,
  //   ),
  //   elevatedButtonTheme: ElevatedButtonThemeData(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: primaryTeal,
  //       foregroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.all(Radius.circular(12)),
  //       ),
  //     ),
  //   ),
  // );
}
