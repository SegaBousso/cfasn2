import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import 'user/home_screen.dart';
import 'user/services/services_list_screen.dart';
import 'user/bookings/my_bookings_screen.dart';
import 'user/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Erreur: Utilisateur non trouvé')),
          );
        }

        // Adapter les pages selon le rôle de l'utilisateur
        final pages = _getPagesForRole(user.role);
        final bottomNavItems = _getBottomNavItemsForRole(user.role);

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: pages),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: bottomNavItems,
          ),
        );
      },
    );
  }

  List<Widget> _getPagesForRole(UserRole role) {
    switch (role) {
      case UserRole.client:
        return [
          const HomeScreen(), // Page d'accueil avec services
          const ServicesListScreen(), // Liste des services
          const MyBookingsScreen(), // Mes réservations
          const ProfileScreen(), // Profil
        ];
      case UserRole.provider:
        // TODO: Implémenter les pages prestataire
        return [
          const HomeScreen(),
          const ServicesListScreen(),
          const MyBookingsScreen(),
          const ProfileScreen(),
        ];
      case UserRole.admin:
        // Les admins utilisent AdminMainScreen, pas ce MainScreen
        // Mais on garde une version de secours au cas où
        return [
          const HomeScreen(),
          const ServicesListScreen(),
          const MyBookingsScreen(),
          const ProfileScreen(),
        ];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.client:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.room_service),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ];
      case UserRole.provider:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Mes Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ];
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room_service),
            label: 'Services',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ];
    }
  }
}
