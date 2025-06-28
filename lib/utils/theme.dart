import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Colors.purple;
  static const Color accentColor = Colors.blue;

  // Couleurs d'état
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color errorColor = Colors.red;
  static const Color infoColor = Colors.blue;

  // Couleurs de texte
  static const Color primaryTextColor = Colors.black87;
  static const Color secondaryTextColor = Colors.black54;
  static const Color whiteTextColor = Colors.white;

  // Couleurs de fond
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: whiteTextColor,
      titleTextStyle: TextStyle(
        fontSize: AppConstants.titleTextSize,
        fontWeight: FontWeight.bold,
        color: whiteTextColor,
      ),
    ),

    // Cartes
    cardTheme: CardThemeData(
      elevation: AppConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      margin: const EdgeInsets.all(AppConstants.smallPadding),
    ),

    // Boutons élevés
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: AppConstants.defaultElevation,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.mediumTextSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Boutons de texte
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.mediumTextSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Boutons outlined
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        side: const BorderSide(color: primaryColor),
        textStyle: const TextStyle(
          fontSize: AppConstants.mediumTextSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Champs de texte
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
    ),

    // ListTile
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
      space: 1,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(color: whiteTextColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      elevation: AppConstants.highElevation,
    ),

    // BottomSheet
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      elevation: AppConstants.highElevation,
    ),
  );

  // Thème sombre
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.grey.shade900,
      foregroundColor: whiteTextColor,
      titleTextStyle: const TextStyle(
        fontSize: AppConstants.titleTextSize,
        fontWeight: FontWeight.bold,
        color: whiteTextColor,
      ),
    ),

    // Cartes
    cardTheme: CardThemeData(
      elevation: AppConstants.defaultElevation,
      color: Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      margin: const EdgeInsets.all(AppConstants.smallPadding),
    ),

    // Personnalisation pour le thème sombre
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: AppConstants.defaultElevation,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.mediumTextSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, primaryColor],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successColor, Colors.lightGreen],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorColor, Colors.redAccent],
  );

  // Ombres
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}

// Extensions pour faciliter l'utilisation des couleurs
extension ColorExtensions on Color {
  /// Retourne une version plus claire de la couleur
  Color get lighter => Color.alphaBlend(Colors.white.withOpacity(0.3), this);

  /// Retourne une version plus sombre de la couleur
  Color get darker => Color.alphaBlend(Colors.black.withOpacity(0.3), this);

  /// Retourne une version semi-transparente de la couleur
  Color withOpacity(double opacity) =>
      Color.fromRGBO(red, green, blue, opacity);
}

// Extensions pour les thèmes
extension ThemeExtensions on ThemeData {
  /// Retourne si le thème est sombre
  bool get isDark => brightness == Brightness.dark;

  /// Retourne si le thème est clair
  bool get isLight => brightness == Brightness.light;

  /// Retourne la couleur de texte principale
  Color get primaryTextColor => isDark ? Colors.white : Colors.black87;

  /// Retourne la couleur de texte secondaire
  Color get secondaryTextColor => isDark ? Colors.white70 : Colors.black54;
}
