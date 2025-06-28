import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../widgets/profile_widgets.dart';

/// Classe pour gérer les dialogues du profil
class ProfileDialogs {
  /// Affiche le dialogue pour changer la photo de profil
  static void showChangeProfilePictureDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                ProfileService.showComingSoonMessage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                ProfileService.showComingSoonMessage(context);
              },
            ),
            if (user.photoURL != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showRemovePhotoConfirmationDialog(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Affiche le dialogue de confirmation pour supprimer la photo
  static void showRemovePhotoConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la photo'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre photo de profil ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          CustomButton(
            text: 'Supprimer',
            backgroundColor: Colors.red,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Photo supprimée')));
            },
          ),
        ],
      ),
    );
  }

  /// Affiche le dialogue de déconnexion
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          CustomButton(
            text: 'Déconnexion',
            backgroundColor: Colors.red,
            onPressed: () async {
              Navigator.pop(context);
              await ProfileService.handleLogout(context);
            },
          ),
        ],
      ),
    );
  }

  /// Affiche le dialogue "À propos"
  static void showAppAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Service App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Service App. Tous droits réservés.',
      children: const [
        Text('Application de réservation de services à domicile.'),
      ],
    );
  }
}
