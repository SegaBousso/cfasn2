import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/models.dart';
import '../../../../providers/auth_provider.dart';

/// Service pour gérer la logique du profil utilisateur
class ProfileService {
  /// Obtient les statistiques utilisateur (mock data pour l'instant)
  static Map<String, dynamic> getUserStats(UserModel user) {
    return {
      'totalBookings': 12,
      'completedBookings': 8,
      'cancelledBookings': 2,
      'favoriteServices': 5,
      'totalSpent': 850.0,
      'reviewsGiven': 6,
    };
  }

  /// Calcule le nombre de jours depuis l'inscription
  static int getDaysSinceRegistration(UserModel user) {
    return DateTime.now().difference(user.createdAt).inDays;
  }

  /// Gère la déconnexion de l'utilisateur
  static Future<void> handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
    }
  }

  /// Affiche un message temporaire pour les fonctionnalités à venir
  static void showComingSoonMessage(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fonctionnalité à venir')));
  }

  /// Navigue vers une route spécifique
  static void navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }
}
