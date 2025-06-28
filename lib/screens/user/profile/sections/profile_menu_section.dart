import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import '../widgets/profile_widgets.dart';
import '../services/profile_service.dart';
import '../dialogs/profile_dialogs.dart';

/// Section du menu de paramètres
class ProfileMenuSection extends StatelessWidget {
  final BuildContext parentContext;

  const ProfileMenuSection({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return AdaptiveContainer(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Paramètres',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          _buildPersonalMenuCard(),
          const SizedBox(height: 16),
          _buildServicesMenuCard(),
          const SizedBox(height: 16),
          _buildSupportMenuCard(),
        ],
      ),
    );
  }

  Widget _buildPersonalMenuCard() {
    return MenuCard(
      children: [
        CustomMenuItem(
          icon: Icons.person,
          title: 'Informations personnelles',
          subtitle: 'Modifier vos données',
          onTap: () =>
              ProfileService.navigateTo(parentContext, '/profile/edit'),
        ),
        CustomMenuItem(
          icon: Icons.security,
          title: 'Sécurité',
          subtitle: 'Mot de passe et authentification',
          onTap: () =>
              ProfileService.navigateTo(parentContext, '/profile/security'),
        ),
        CustomMenuItem(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Gérer vos préférences',
          onTap: () => ProfileService.navigateTo(
            parentContext,
            '/profile/notifications',
          ),
        ),
      ],
    );
  }

  Widget _buildServicesMenuCard() {
    return MenuCard(
      children: [
        CustomMenuItem(
          icon: Icons.payment,
          title: 'Moyens de paiement',
          subtitle: 'Cartes et portefeuilles',
          onTap: () =>
              ProfileService.navigateTo(parentContext, '/profile/payments'),
        ),
        CustomMenuItem(
          icon: Icons.history,
          title: 'Historique',
          subtitle: 'Toutes vos réservations',
          onTap: () =>
              ProfileService.navigateTo(parentContext, '/bookings/history'),
        ),
        CustomMenuItem(
          icon: Icons.favorite,
          title: 'Mes favoris',
          subtitle: 'Services sauvegardés',
          onTap: () => ProfileService.navigateTo(parentContext, '/favorites'),
        ),
      ],
    );
  }

  Widget _buildSupportMenuCard() {
    return MenuCard(
      children: [
        CustomMenuItem(
          icon: Icons.help,
          title: 'Aide et support',
          subtitle: 'FAQ et contact',
          onTap: () => ProfileService.navigateTo(parentContext, '/help'),
        ),
        CustomMenuItem(
          icon: Icons.info,
          title: 'À propos',
          subtitle: 'Version et informations',
          onTap: () => ProfileDialogs.showAppAboutDialog(parentContext),
        ),
        CustomMenuItem(
          icon: Icons.logout,
          title: 'Déconnexion',
          subtitle: 'Se déconnecter du compte',
          onTap: () => ProfileDialogs.showLogoutDialog(parentContext),
          textColor: Colors.red,
        ),
      ],
    );
  }
}
