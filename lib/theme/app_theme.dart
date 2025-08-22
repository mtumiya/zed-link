import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1565C0); // Deep blue
  static const Color secondaryColor = Color(0xFF43A047); // Green for success/delivery
  static const Color accentColor = Color(0xFFFF8F00); // Orange for notifications/alerts
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFF6F00);
  static const Color successColor = Color(0xFF388E3C);
  
  // Surface colors for cards, sheets, etc.
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color outlineColor = Color(0xFF79747E);
  
  // Background colors
  static const Color backgroundColor = Color(0xFFFFFBFE);
  static const Color onBackgroundColor = Color(0xFF1C1B1F);

  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.light,
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: accentColor,
    error: errorColor,
    surface: surfaceColor,
    onSurface: onSurfaceColor,
    outline: outlineColor,
    background: backgroundColor,
    onBackground: onBackgroundColor,
  );

  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.dark,
    primary: const Color(0xFF90CAF9),
    secondary: const Color(0xFF81C784),
    tertiary: const Color(0xFFFFB74D),
    error: const Color(0xFFEF5350),
    surface: const Color(0xFF121212),
    onSurface: const Color(0xFFE5E5E5),
    outline: const Color(0xFF938F99),
    background: const Color(0xFF121212),
    onBackground: const Color(0xFFE5E5E5),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    fontFamily: 'Roboto', // Using Roboto as the default system font
    
    // AppBar theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: lightColorScheme.surface,
      foregroundColor: lightColorScheme.onSurface,
      surfaceTintColor: lightColorScheme.surfaceTint,
      titleTextStyle: TextStyle(
        color: lightColorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    
    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: lightColorScheme.outline),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    
    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightColorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        color: lightColorScheme.onSurfaceVariant,
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
      hintStyle: TextStyle(
        color: lightColorScheme.onSurfaceVariant.withOpacity(0.6),
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: lightColorScheme.surface,
      selectedItemColor: lightColorScheme.primary,
      unselectedItemColor: lightColorScheme.onSurfaceVariant,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
    ),
    
    // List tile theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: TextStyle(
        color: lightColorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
      subtitleTextStyle: TextStyle(
        color: lightColorScheme.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: lightColorScheme.surfaceVariant,
      labelStyle: TextStyle(
        color: lightColorScheme.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    
    // Floating action button theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Snack bar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightColorScheme.inverseSurface,
      contentTextStyle: TextStyle(
        color: lightColorScheme.onInverseSurface,
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    fontFamily: 'Roboto',
    
    // AppBar theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: darkColorScheme.surface,
      foregroundColor: darkColorScheme.onSurface,
      surfaceTintColor: darkColorScheme.surfaceTint,
      titleTextStyle: TextStyle(
        color: darkColorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Similar theme configurations for other components...
    // (Following same pattern as light theme but with dark colors)
  );

  // Custom text styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    fontFamily: 'Roboto',
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    fontFamily: 'Roboto',
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: 'Roboto',
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    height: 1.4,
  );
}