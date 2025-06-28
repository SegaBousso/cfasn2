import 'package:flutter/material.dart';
import '../../models/models.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  // Mock data pour les statistiques
  final Map<String, dynamic> _stats = {
    'totalBookings': 47,
    'pendingBookings': 5,
    'completedBookings': 38,
    'cancelledBookings': 4,
    'totalRevenue': 2850.0,
    'monthlyRevenue': 450.0,
    'averageRating': 4.6,
    'totalReviews': 23,
  };

  // Mock data pour les réservations récentes
  final List<Map<String, dynamic>> _recentBookings = [
    {
      'id': '1',
      'serviceName': 'Nettoyage de bureaux',
      'clientName': 'Marie Dubois',
      'scheduledDate': DateTime.now().add(const Duration(hours: 3)),
      'location': '123 Rue de la Paix, Paris',
      'totalPrice': 80.0,
      'status': BookingStatus.confirmed,
    },
    {
      'id': '2',
      'serviceName': 'Réparation plomberie',
      'clientName': 'Jean Martin',
      'scheduledDate': DateTime.now().add(const Duration(days: 1)),
      'location': '45 Avenue des Champs, Lyon',
      'totalPrice': 120.0,
      'status': BookingStatus.pending,
    },
    {
      'id': '3',
      'serviceName': 'Cours de guitare',
      'clientName': 'Sophie Laurent',
      'scheduledDate': DateTime.now().add(const Duration(days: 2)),
      'location': '78 Rue Mozart, Toulouse',
      'totalPrice': 50.0,
      'status': BookingStatus.confirmed,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading:
            false, // Empêche l'affichage de l'icône de retour
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/provider/profile');
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/provider/settings');
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Mon Profil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentBookings(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/provider/services/create');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(Icons.business, color: Colors.green, size: 30),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      'Jean Dupont',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Vos services performent bien ce mois-ci !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'Réservations',
          value: '${_stats['totalBookings']}',
          subtitle: '${_stats['pendingBookings']} en attente',
          icon: Icons.calendar_today,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Revenus',
          value: '${_stats['totalRevenue'].toStringAsFixed(0)}€',
          subtitle: '+${_stats['monthlyRevenue'].toStringAsFixed(0)}€ ce mois',
          icon: Icons.euro,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Note moyenne',
          value: '${_stats['averageRating']}/5',
          subtitle: '${_stats['totalReviews']} avis',
          icon: Icons.star,
          color: Colors.amber,
        ),
        _buildStatCard(
          title: 'Terminées',
          value: '${_stats['completedBookings']}',
          subtitle: 'Ce mois',
          icon: Icons.check_circle,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Mes Services',
                subtitle: 'Gérer mes offres',
                icon: Icons.build,
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/provider/services'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Réservations',
                subtitle: 'Voir toutes',
                icon: Icons.event_note,
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/provider/bookings'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Finances',
                subtitle: 'Revenus & paiements',
                icon: Icons.account_balance_wallet,
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, '/provider/finances'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Avis',
                subtitle: 'Voir les retours',
                icon: Icons.reviews,
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/provider/reviews'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Réservations récentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/provider/bookings');
              },
              child: const Text('Voir toutes'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentBookings.length,
          itemBuilder: (context, index) {
            final booking = _recentBookings[index];
            return _buildBookingCard(booking);
          },
        ),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(booking['status']).withOpacity(0.1),
          child: Icon(
            _getStatusIcon(booking['status']),
            color: _getStatusColor(booking['status']),
          ),
        ),
        title: Text(
          booking['serviceName'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${booking['clientName']}'),
            Text(
              _formatDateTime(booking['scheduledDate']),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${booking['totalPrice'].toStringAsFixed(0)}€',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            _buildStatusChip(booking['status']),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/provider/booking/detail',
            arguments: booking,
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.hourglass_empty;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.inProgress:
        return Icons.play_circle;
      case BookingStatus.completed:
        return Icons.check_circle_outline;
      case BookingStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Demain ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Logique de déconnexion ici
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simuler le rechargement des données
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Les données seraient rechargées depuis l'API ici
    });
  }
}
