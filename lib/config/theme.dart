import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  // Primary colors
  static const Color primaryLight = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1E88E5); // Slightly darker blue

  // Accent/secondary colors
  static const Color secondaryLight = Color(0xFF448AFF); // Blue accent
  static const Color secondaryDark = Color(0xFF2979FF); // Darker blue accent

  // Background colors
  static const Color backgroundLight = Color(0xFFFFFFFF); // White
  static const Color backgroundDark = Color(0xFF303030); // Dark grey

  // Surface colors (for cards, etc.)
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color surfaceDark = Color(0xFF424242); // Medium grey

  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121); // Nearly black
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White
  static const Color textSecondaryLight = Color(0xFF757575); // Medium grey
  static const Color textSecondaryDark = Color(0xFFBDBDBD); // Light grey

  // Error colors
  static const Color errorLight = Color(0xFFE53935); // Red
  static const Color errorDark = Color(0xFFEF5350); // Lighter red
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme') ?? 'system';

    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    String themeString = 'system';

    if (mode == ThemeMode.light) {
      themeString = 'light';
    } else if (mode == ThemeMode.dark) {
      themeString = 'dark';
    }

    await prefs.setString('theme', themeString);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        error: AppColors.errorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardTheme: CardTheme(
        color: AppColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
        bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
        bodySmall: TextStyle(color: AppColors.textSecondaryLight),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primaryDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.errorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
        bodySmall: TextStyle(color: AppColors.textSecondaryDark),
      ),
    );
  }
}
