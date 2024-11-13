import 'package:flutter/material.dart';

// Your existing ThemeProvider
class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) updateTheme;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.updateTheme,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

// Add a Theme class to manage your theme data
class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
      primary: Colors.blue,
      secondary: Colors.blue.shade700,
      tertiary: Colors.blue.shade300,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    ),
    // Card theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    // AppBar theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
      primary: Colors.blue,
      secondary: Colors.blue.shade300,
      tertiary: Colors.blue.shade200,
      surface: const Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    // Card theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    // AppBar theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
  );
}
