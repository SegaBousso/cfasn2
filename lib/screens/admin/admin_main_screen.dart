import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import 'admin_dashboard_screen.dart';
import 'users/users_management_screen.dart';
import 'services/services_management_screen.dart';
import 'categories/categories_management_screen.dart';
import 'providers/providers_management_screen.dart';
import 'bookings/bookings_management_screen.dart';
import '../user/profile/profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  // Pages d'administration
  final List<Widget> _adminPages = [
    const AdminDashboardScreen(), // Dashboard principal
    const UsersManagementScreen(), // Gestion des utilisateurs
    const ServicesManagementScreen(), // Gestion des services
    const CategoriesManagementScreen(), // Gestion des catégories
    const ProvidersManagementScreen(), // Gestion des prestataires
    const BookingsManagementScreen(), // Gestion des réservations
    const ProfileScreen(), // Profil admin
  ];

  // Items de navigation pour admin
  final List<BottomNavigationBarItem> _adminNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Utilisateurs',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.room_service),
      label: 'Services',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.category),
      label: 'Catégories',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.business),
      label: 'Prestataires',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Réservations',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        // Vérifier que l'utilisateur est bien admin
        if (user == null || user.role != UserRole.admin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Accès refusé'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Accès administrateur requis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas les permissions nécessaires.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _adminPages),
          bottomNavigationBar: _buildAdminBottomNavigation(),
          drawer: _buildAdminDrawer(context, user),
        );
      },
    );
  }

  Widget _buildAdminBottomNavigation() {
    // Si nous avons plus de 5 items, utilisons un Drawer principal
    // et gardons seulement les items principaux dans la bottom nav
    final mainNavItems = _adminNavItems.take(4).toList();
    mainNavItems.add(
      const BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
    );

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex > 4 ? 4 : _currentIndex,
      onTap: (index) {
        if (index == 4) {
          // Ouvrir le drawer
          Scaffold.of(context).openDrawer();
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      selectedItemColor: Colors.red[700],
      unselectedItemColor: Colors.grey,
      items: mainNavItems,
    );
  }

  Widget _buildAdminDrawer(BuildContext context, UserModel user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[700]!, Colors.red[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administrateur',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Navigation items
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: _currentIndex == 0,
            onTap: () {
              _navigateToPage(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Utilisateurs'),
            selected: _currentIndex == 1,
            onTap: () {
              _navigateToPage(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.room_service),
            title: const Text('Services'),
            selected: _currentIndex == 2,
            onTap: () {
              _navigateToPage(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Catégories'),
            selected: _currentIndex == 3,
            onTap: () {
              _navigateToPage(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Prestataires'),
            selected: _currentIndex == 4,
            onTap: () {
              _navigateToPage(4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Réservations'),
            selected: _currentIndex == 5,
            onTap: () {
              _navigateToPage(5);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon Profil'),
            selected: _currentIndex == 6,
            onTap: () {
              _navigateToPage(6);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              // TODO: Naviguer vers paramètres admin
              Navigator.pop(context);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context); // Fermer le drawer
  }

  void _showLogoutDialog(BuildContext context) {
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
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/auth',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
