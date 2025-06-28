// Constantes pour l'application
class AppConstants {
  // Informations de l'application
  static const String appName = 'Service Auth';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Système d\'authentification Flutter avec Google Sign-In';

  // Collections Firestore
  static const String usersCollection = 'users';

  // Messages d'erreur
  static const String networkErrorMessage =
      'Erreur de réseau. Vérifiez votre connexion internet.';
  static const String unknownErrorMessage =
      'Une erreur inattendue s\'est produite.';
  static const String authCancelledMessage =
      'Connexion annulée par l\'utilisateur.';

  // Messages de succès
  static const String signInSuccessMessage = 'Connexion réussie !';
  static const String signOutSuccessMessage = 'Déconnexion réussie !';
  static const String accountDeletedMessage = 'Compte supprimé avec succès.';

  // Durées d'animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  // Bordures et rayons
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Espacements
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Tailles d'icônes
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;

  // Tailles de texte
  static const double smallTextSize = 12.0;
  static const double defaultTextSize = 14.0;
  static const double mediumTextSize = 16.0;
  static const double largeTextSize = 18.0;
  static const double titleTextSize = 20.0;
  static const double headingTextSize = 24.0;
  static const double largeHeadingTextSize = 32.0;

  // Élévations
  static const double lowElevation = 2.0;
  static const double defaultElevation = 4.0;
  static const double highElevation = 8.0;

  // URLs et liens
  static const String privacyPolicyUrl = 'https://your-privacy-policy-url.com';
  static const String termsOfServiceUrl =
      'https://your-terms-of-service-url.com';
  static const String supportEmail = 'support@your-app.com';

  // Formats de date
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}

// Clés de préférences
class PreferenceKeys {
  static const String isFirstLaunch = 'isFirstLaunch';
  static const String themeMode = 'themeMode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notificationsEnabled';
}

// Routes de navigation
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

// Codes d'erreur personnalisés
class ErrorCodes {
  static const String networkError = 'NETWORK_ERROR';
  static const String authError = 'AUTH_ERROR';
  static const String firestoreError = 'FIRESTORE_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';
  static const String permissionError = 'PERMISSION_ERROR';
}

// Types d'événements analytics
class AnalyticsEvents {
  static const String signIn = 'sign_in';
  static const String signOut = 'sign_out';
  static const String deleteAccount = 'delete_account';
  static const String viewProfile = 'view_profile';
  static const String updateProfile = 'update_profile';
}
