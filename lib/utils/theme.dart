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
  static const Color backgroundLight = Color(0xFFE0E4E2);      // Smooth stone
  static const Color backgroundExtraLight = Color(0xFFF2F5F3); // River foam
  static const Color accentLight = Color(0xFFE0783D);          // Koi orange
  static const Color primaryTextLight = Color(0xFF363B39);     // Deep slate
  static const Color textSecondaryLight = Color(0xFF5B5F5D);   // River rock
  static const Color circleLight = Color(0xFF6E7975);          // River reed
  static const Color buttonBackgroundLight = Color(0xFFD4D9D6); // Pebble

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF151817);       // Night water
  static const Color backgroundExtraDark = Color(0xFF202322);  // Deep river
  static const Color accentDark = Color(0xFFEF8A49);           // Autumn leaf
  static const Color primaryTextDark = Color(0xFFE2E6E4);      // Moon reflection
  static const Color textSecondaryDark = Color(0xFFB2B6B4);    // Morning mist
  static const Color circleDark = Color(0xFF535E5A);           // Moss stone
  static const Color buttonBackgroundDark = Color(0xFF2A2D2B); // Riverbed
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
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryTextLight,
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
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.primaryTextDark,
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