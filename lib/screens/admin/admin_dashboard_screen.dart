import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/overflow_safe_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Empêche l'affichage de l'icône de retour
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
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec statistiques
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                      const Text(
                        'Tableau de bord',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vue d\'ensemble de la plateforme',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Statistiques principales
                const Text(
                  'Statistiques générales',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people,
                        title: 'Utilisateurs',
                        value: '1,234',
                        color: Colors.blue,
                        trend: '+12%',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.business,
                        title: 'Prestataires',
                        value: '156',
                        color: Colors.green,
                        trend: '+8%',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.build,
                        title: 'Services',
                        value: '487',
                        color: Colors.orange,
                        trend: '+15%',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_today,
                        title: 'Réservations',
                        value: '2,891',
                        color: Colors.purple,
                        trend: '+23%',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Actions rapides
                const Text(
                  'Actions administratives',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ResponsiveBuilder(
                  builder: (context, dimensions) {
                    final crossAxisCount = dimensions.isDesktop
                        ? 4
                        : dimensions.isTablet
                        ? 3
                        : 2;
                    // Augmenter significativement l'aspect ratio pour plus d'espace vertical
                    final aspectRatio = dimensions.isDesktop
                        ? 1.8
                        : dimensions.isTablet
                        ? 1.7
                        : 2.0; // Plus d'espace vertical pour éviter l'overflow

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing:
                          ResponsiveHelper.getSpacing(context) * 0.75,
                      mainAxisSpacing:
                          ResponsiveHelper.getSpacing(context) * 0.75,
                      childAspectRatio: aspectRatio,
                      children: [
                        _buildActionCard(
                          icon: Icons.people_alt,
                          title: 'Gestion Utilisateurs',
                          subtitle: 'Gérer les comptes utilisateurs',
                          color: Colors.blue,
                          onTap: () => _navigateToUsersManagement(),
                        ),
                        _buildActionCard(
                          icon: Icons.verified_user,
                          title: 'Gestion Prestataires',
                          subtitle: 'Gérer les prestataires',
                          color: Colors.green,
                          onTap: () => _navigateToProvidersManagement(),
                        ),
                        _buildActionCard(
                          icon: Icons.bookmark,
                          title: 'Gestion Réservations',
                          subtitle: 'Gérer toutes les réservations',
                          color: Colors.purple,
                          onTap: () => _navigateToBookingsManagement(),
                        ),
                        _buildActionCard(
                          icon: Icons.build,
                          title: 'Gestion Services',
                          subtitle: 'Gérer les services proposés',
                          color: Colors.orange,
                          onTap: () => _navigateToServicesManagement(),
                        ),
                        _buildActionCard(
                          icon: Icons.category,
                          title: 'Gestion Catégories',
                          subtitle: 'Gérer les catégories',
                          color: Colors.teal,
                          onTap: () => _navigateToCategoriesManagement(),
                        ),
                        _buildActionCard(
                          icon: Icons.report_problem,
                          title: 'Modération',
                          subtitle: 'Gérer les signalements',
                          color: Colors.orange,
                          onTap: () => _navigateToModeration(),
                        ),
                        _buildActionCard(
                          icon: Icons.analytics,
                          title: 'Analytics',
                          subtitle: 'Voir les rapports détaillés',
                          color: Colors.purple,
                          onTap: () => _navigateToAnalytics(),
                        ),
                        _buildActionCard(
                          icon: Icons.money,
                          title: 'Finances',
                          subtitle: 'Gérer les transactions',
                          color: Colors.teal,
                          onTap: () => _navigateToFinances(),
                        ),
                        _buildActionCard(
                          icon: Icons.support_agent,
                          title: 'Support',
                          subtitle: 'Tickets et assistance',
                          color: Colors.indigo,
                          onTap: () => _navigateToSupport(),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Alertes et notifications
                const Text(
                  'Alertes système',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildAlertCard(
                  icon: Icons.warning,
                  title: '3 nouveaux signalements',
                  subtitle: 'Nécessitent une attention immédiate',
                  color: Colors.red,
                  onTap: () => _navigateToReports(),
                ),

                const SizedBox(height: 12),

                _buildAlertCard(
                  icon: Icons.pending_actions,
                  title: '8 prestataires en attente',
                  subtitle: 'Vérification de documents requise',
                  color: Colors.orange,
                  onTap: () => _navigateToPendingProviders(),
                ),

                const SizedBox(height: 12),

                _buildAlertCard(
                  icon: Icons.system_update,
                  title: 'Mise à jour système',
                  subtitle: 'Maintenance prévue ce weekend',
                  color: Colors.blue,
                  onTap: () => _navigateToSystemUpdate(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ResponsiveBuilder(
      builder: (context, dimensions) {
        return AdaptiveContainer(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(dimensions.isDesktop ? 8.0 : 6.0),
                child: OverflowSafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icône avec container compact
                      Container(
                        padding: EdgeInsets.all(
                          dimensions.isDesktop ? 6.0 : 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: dimensions.isDesktop ? 20 : 16,
                        ),
                      ),
                      SizedBox(height: dimensions.isDesktop ? 6.0 : 4.0),

                      // Titre avec gestion responsive
                      AdaptiveText(
                        title,
                        style: TextStyle(
                          fontSize: dimensions.isDesktop ? 10 : 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                      SizedBox(height: dimensions.isDesktop ? 2.0 : 1.0),

                      // Sous-titre avec gestion responsive
                      AdaptiveText(
                        subtitle,
                        style: TextStyle(
                          fontSize: dimensions.isDesktop ? 8 : 7,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
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

  void _navigateToModeration() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Modération - à implémenter')));
  }

  void _navigateToAnalytics() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Analytics - à implémenter')));
  }

  void _navigateToFinances() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Finances - à implémenter')));
  }

  void _navigateToSupport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Support - à implémenter')));
  }

  void _navigateToReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signalements - à implémenter')),
    );
  }

  void _navigateToPendingProviders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prestataires en attente - à implémenter')),
    );
  }

  void _navigateToSystemUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mise à jour système - à implémenter')),
    );
  }
}
