import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/overflow_safe_widgets.dart';

class ResponsiveAdminDashboard extends StatefulWidget {
  const ResponsiveAdminDashboard({super.key});

  @override
  State<ResponsiveAdminDashboard> createState() =>
      _ResponsiveAdminDashboardState();
}

class _ResponsiveAdminDashboardState extends State<ResponsiveAdminDashboard>
    with ResponsiveMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigation vers paramètres admin
            },
          ),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, dimensions) {
          return OverflowSafeArea(
            padding: ResponsiveHelper.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec statistiques responsive
                _buildStatsHeader(context, dimensions),

                SizedBox(
                  height: context.responsiveSpacing(
                    mobile: 16,
                    tablet: 24,
                    desktop: 32,
                  ),
                ),

                // Actions administratives responsive
                _buildActionsSection(context, dimensions),

                SizedBox(
                  height: context.responsiveSpacing(
                    mobile: 16,
                    tablet: 24,
                    desktop: 32,
                  ),
                ),

                // Alertes système responsive
                _buildAlertsSection(context, dimensions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(
    BuildContext context,
    ResponsiveDimensions dimensions,
  ) {
    return ResponsiveContainer(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(
          context.responsiveSpacing(mobile: 16, tablet: 20, desktop: 24),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[700]!, Colors.red[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdaptiveText(
              'Tableau de bord',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.responsiveFontSize(
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: context.responsiveSpacing(
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
            AdaptiveText(
              'Vue d\'ensemble de la plateforme',
              style: TextStyle(
                color: Colors.white70,
                fontSize: context.responsiveFontSize(
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
              ),
            ),
            SizedBox(
              height: context.responsiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),

            // Statistiques en grille responsive
            ResponsiveGrid(
              mobileColumns: 2,
              tabletColumns: 4,
              desktopColumns: 4,
              spacing: context.responsiveSpacing(
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
              runSpacing: context.responsiveSpacing(
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.people,
                  title: 'Utilisateurs',
                  value: '1,234',
                  color: Colors.white,
                  textColor: Colors.red[700]!,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.verified_user,
                  title: 'Prestataires',
                  value: '156',
                  color: Colors.white,
                  textColor: Colors.red[700]!,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.build,
                  title: 'Services',
                  value: '487',
                  color: Colors.white,
                  textColor: Colors.red[700]!,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Réservations',
                  value: '2,891',
                  color: Colors.white,
                  textColor: Colors.red[700]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    ResponsiveDimensions dimensions,
  ) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Actions administratives',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobile: 18,
                tablet: 20,
                desktop: 24,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: context.responsiveSpacing(
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),

          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 3,
            spacing: context.responsiveSpacing(
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
            runSpacing: context.responsiveSpacing(
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildActionCard(
                context,
                icon: Icons.people_alt,
                title: 'Gestion Utilisateurs',
                subtitle: 'Gérer les comptes utilisateurs',
                color: Colors.blue,
                onTap: () => _navigateToUsersManagement(),
              ),
              _buildActionCard(
                context,
                icon: Icons.verified_user,
                title: 'Gestion Prestataires',
                subtitle: 'Gérer les prestataires',
                color: Colors.green,
                onTap: () => _navigateToProvidersManagement(),
              ),
              _buildActionCard(
                context,
                icon: Icons.bookmark,
                title: 'Gestion Réservations',
                subtitle: 'Gérer toutes les réservations',
                color: Colors.purple,
                onTap: () => _navigateToBookingsManagement(),
              ),
              _buildActionCard(
                context,
                icon: Icons.build,
                title: 'Gestion Services',
                subtitle: 'Gérer les services proposés',
                color: Colors.orange,
                onTap: () => _navigateToServicesManagement(),
              ),
              _buildActionCard(
                context,
                icon: Icons.category,
                title: 'Gestion Catégories',
                subtitle: 'Gérer les catégories',
                color: Colors.teal,
                onTap: () => _navigateToCategoriesManagement(),
              ),
              _buildActionCard(
                context,
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'Voir les rapports détaillés',
                color: Colors.indigo,
                onTap: () => _navigateToAnalytics(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(
    BuildContext context,
    ResponsiveDimensions dimensions,
  ) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Alertes système',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobile: 18,
                tablet: 20,
                desktop: 24,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: context.responsiveSpacing(
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),

          Column(
            children: [
              _buildAlertCard(
                context,
                icon: Icons.warning,
                title: 'Mise à jour disponible',
                subtitle: 'Version 2.1.0 disponible',
                color: Colors.orange,
                onTap: () => _navigateToSystemUpdate(),
              ),
              SizedBox(
                height: context.responsiveSpacing(
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              _buildAlertCard(
                context,
                icon: Icons.report_problem,
                title: '3 signalements en attente',
                subtitle: 'Nécessitent votre attention',
                color: Colors.red,
                onTap: () => _navigateToReports(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return AdaptiveContainer(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(
        context.responsiveSpacing(mobile: 12, tablet: 16, desktop: 20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: textColor,
            size: context.responsiveFontSize(
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
          ),
          SizedBox(
            height: context.responsiveSpacing(mobile: 4, tablet: 6, desktop: 8),
          ),
          AdaptiveText(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: context.responsiveFontSize(
                mobile: 18,
                tablet: 20,
                desktop: 24,
              ),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
          AdaptiveText(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: context.responsiveFontSize(
                mobile: 10,
                tablet: 12,
                desktop: 14,
              ),
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AdaptiveContainer(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(
              context.responsiveSpacing(mobile: 16, tablet: 20, desktop: 24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    context.responsiveSpacing(
                      mobile: 12,
                      tablet: 16,
                      desktop: 20,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: context.responsiveFontSize(
                      mobile: 28,
                      tablet: 32,
                      desktop: 36,
                    ),
                  ),
                ),
                SizedBox(
                  height: context.responsiveSpacing(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                AdaptiveText(
                  title,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: context.responsiveSpacing(
                    mobile: 4,
                    tablet: 6,
                    desktop: 8,
                  ),
                ),
                AdaptiveText(
                  subtitle,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobile: 11,
                      tablet: 12,
                      desktop: 14,
                    ),
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AdaptiveContainer(
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          title: AdaptiveText(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: context.responsiveFontSize(
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
            maxLines: 1,
          ),
          subtitle: AdaptiveText(
            subtitle,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
            maxLines: 2,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  // Méthodes de navigation
  void _navigateToUsersManagement() {
    Navigator.pushNamed(context, '/admin/users');
  }

  void _navigateToProvidersManagement() {
    Navigator.pushNamed(context, '/admin/providers');
  }

  void _navigateToBookingsManagement() {
    Navigator.pushNamed(context, '/admin/bookings');
  }

  void _navigateToServicesManagement() {
    Navigator.pushNamed(context, '/admin/services');
  }

  void _navigateToCategoriesManagement() {
    Navigator.pushNamed(context, '/admin/categories');
  }

  void _navigateToAnalytics() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Analytics - à implémenter')));
  }

  void _navigateToReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signalements - à implémenter')),
    );
  }

  void _navigateToSystemUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mise à jour système - à implémenter')),
    );
  }
}
