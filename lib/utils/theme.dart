import 'package:flutter/material.dart';

// Extension defined at the top level, outside any class
extension ColorWithValues on Color {
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromARGB(
      (alpha != null ? (alpha * 255).round() : this.alpha),
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}

class AppColors {
  // Light theme colors
  static const Color backgroundLight = Color.fromARGB(255, 217, 212, 195);
  static const Color backgroundExtraLight = Color.fromARGB(255, 238, 237, 233);
  static const Color accentLight = Color(0xFFD4956A);
  static const Color primaryTextLight = Color(0xFF464C3B);
  static const Color textSecondaryLight = Color(0xFF5A6353);
  static const Color circleLight = Color(0xFF5F6B51);
  static const Color buttonBackgroundLight = Color(0xFFE8E3CE);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF1E2119);
  static const Color backgroundExtraDark = Color(0xFF282E24);
  static const Color accentDark = Color(0xFFE2A87A); // Lighter for better visibility
  static const Color primaryTextDark = Color(0xFFE5E1D0);
  static const Color textSecondaryDark = Color(0xFFBBB8A9);
  static const Color circleDark = Color(0xFF758064);
  static const Color buttonBackgroundDark = Color(0xFF3C4434);
}

class AppTheme {
  // Light theme (based on your existing theme)
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryTextLight,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentLight,
        secondary: AppColors.accentLight,
        surface: AppColors.backgroundExtraLight,
        background: AppColors.backgroundLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryTextLight,
        onBackground: AppColors.primaryTextLight,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.primaryTextLight,
          fontWeight: FontWeight.w300,
          fontSize: 28,
        ),
        displayMedium: TextStyle(
          color: AppColors.primaryTextLight,
          fontWeight: FontWeight.w400,
          fontSize: 24,
        ),
        displaySmall: TextStyle(
          color: AppColors.primaryTextLight,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(
          color: AppColors.primaryTextLight,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.primaryTextLight,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackgroundLight,
          foregroundColor: AppColors.primaryTextLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTextLight,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryTextDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentDark,
        secondary: AppColors.accentDark,
        surface: AppColors.backgroundExtraDark,
        background: AppColors.backgroundDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.primaryTextDark,
        onBackground: AppColors.primaryTextDark,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.primaryTextDark,
          fontWeight: FontWeight.w300,
          fontSize: 28,
        ),
        displayMedium: TextStyle(
          color: AppColors.primaryTextDark,
          fontWeight: FontWeight.w400,
          fontSize: 24,
        ),
        displaySmall: TextStyle(
          color: AppColors.primaryTextDark,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(
          color: AppColors.primaryTextDark,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.primaryTextDark,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackgroundDark,
          foregroundColor: AppColors.primaryTextDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTextDark,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Helper methods to get theme-aware colors
  static Color primaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.primaryTextLight
        : AppColors.primaryTextDark;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.backgroundLight
        : AppColors.backgroundDark;
  }

  static Color backgroundLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.backgroundExtraLight
        : AppColors.backgroundExtraDark;
  }

  static Color buttonBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.buttonBackgroundLight
        : AppColors.buttonBackgroundDark;
  }

  static Color accent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.accentLight
        : AppColors.accentDark;
  }

  static Color circle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.circleLight
        : AppColors.circleDark;
  }
}

// Keep the original appTheme for backward compatibility
final ThemeData appTheme = AppTheme.getLightTheme();