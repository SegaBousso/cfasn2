import 'package:flutter/material.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/profile/profile_screen.dart';
import 'screens/user/services/services_list_screen.dart';
import 'screens/user/services/service_detail_screen.dart';
import 'screens/user/bookings/create_booking_screen.dart';
import 'screens/user/bookings/my_bookings_screen.dart';
import 'screens/provider/provider_home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/users/users_management_screen.dart';
import 'screens/admin/services/services_management_screen.dart';
import 'screens/admin/providers/providers_management_screen.dart';
import 'screens/admin/categories/categories_management_screen.dart';
import 'screens/admin/bookings/bookings_management_screen.dart';
import 'screens/admin/bookings/booking_details_screen.dart';
import 'screens/examples/responsive_design_showcase.dart';
import 'models/models.dart';

class AppRoutes {
  // Routes d'authentification
  static const String auth = '/auth';
  static const String login = '/login';
  static const String completeProfile = '/auth/complete-profile';

  // Routes utilisateur
  static const String userHome = '/user/home';
  static const String userProfile = '/user/profile';
  static const String userServices = '/user/services';
  static const String serviceDetail = '/user/services/detail';
  static const String createBooking = '/user/bookings/create';
  static const String myBookings = '/user/bookings';

  // Routes prestataire
  static const String providerHome = '/provider/home';

  // Routes admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminServices = '/admin/services';
  static const String adminProviders = '/admin/providers';
  static const String adminCategories = '/admin/categories';
  static const String adminBookings = '/admin/bookings';
  static const String adminBookingDetails = '/admin/bookings/details';

  // Routes exemples
  static const String responsiveShowcase = '/examples/responsive';

  static Map<String, WidgetBuilder> get routes {
    return {
      auth: (context) => const AuthWrapper(),
      login: (context) => const LoginScreen(),
      completeProfile: (context) => const CompleteProfileScreen(),
      userHome: (context) => const HomeScreen(),
      userProfile: (context) => const ProfileScreen(),
      userServices: (context) => const ServicesListScreen(),
      myBookings: (context) => const MyBookingsScreen(),
      providerHome: (context) => const ProviderHomeScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      adminUsers: (context) => const UsersManagementScreen(),
      adminServices: (context) => const ServicesManagementScreen(),
      adminProviders: (context) => const ProvidersManagementScreen(),
      adminCategories: (context) => const CategoriesManagementScreen(),
      adminBookings: (context) => const BookingsManagementScreen(),
      responsiveShowcase: (context) => const ResponsiveDesignShowcase(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case serviceDetail:
        if (settings.arguments is ServiceModel) {
          return MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(
              service: settings.arguments as ServiceModel,
            ),
            settings: settings,
          );
        }
        return _errorRoute('Service non trouvé');

      case createBooking:
        if (settings.arguments is ServiceModel) {
          return MaterialPageRoute(
            builder: (context) => CreateBookingScreen(
              service: settings.arguments as ServiceModel,
            ),
            settings: settings,
          );
        }
        return _errorRoute('Service requis pour la réservation');

      case adminBookingDetails:
        if (settings.arguments is String) {
          return MaterialPageRoute(
            builder: (context) =>
                BookingDetailsScreen(bookingId: settings.arguments as String),
            settings: settings,
          );
        }
        return _errorRoute('ID de réservation requis');

      default:
        return _errorRoute('Route non trouvée: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erreur de Navigation',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(auth, (route) => false);
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension pour faciliter la navigation
extension NavigationHelper on BuildContext {
  // Navigation simple
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  // Navigation avec remplacement
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(
      this,
    ).pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }

  // Navigation avec suppression de toutes les routes précédentes
  Future<T?> pushNamedAndRemoveUntil<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Retour en arrière
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  // Vérifier si on peut revenir en arrière
  bool canPop() {
    return Navigator.of(this).canPop();
  }
}

// Classe utilitaire pour la navigation basée sur les rôles
class RoleBasedNavigation {
  static String getHomeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.client:
        return AppRoutes.userHome;
      case UserRole.provider:
        return AppRoutes.providerHome;
      case UserRole.admin:
        return AppRoutes.adminDashboard;
    }
  }

  static List<String> getAccessibleRoutesForRole(UserRole role) {
    switch (role) {
      case UserRole.client:
        return [
          AppRoutes.userHome,
          AppRoutes.userProfile,
          AppRoutes.userServices,
          AppRoutes.serviceDetail,
          AppRoutes.createBooking,
          AppRoutes.myBookings,
        ];
      case UserRole.provider:
        return [
          AppRoutes.providerHome,
          AppRoutes.userProfile, // Peut voir son profil
        ];
      case UserRole.admin:
        return [
          AppRoutes.adminDashboard,
          AppRoutes.adminUsers,
          AppRoutes.adminServices,
          AppRoutes.adminProviders,
          AppRoutes.adminCategories,
          AppRoutes.userProfile, // Peut voir son profil
        ];
    }
  }

  static bool canAccessRoute(UserRole role, String route) {
    return getAccessibleRoutesForRole(role).contains(route);
  }
}

// Navigation Guards
class NavigationGuard {
  static Route<dynamic>? checkAccess(
    RouteSettings settings,
    UserRole? userRole,
  ) {
    if (userRole == null) {
      // Utilisateur non connecté, rediriger vers l'authentification
      return MaterialPageRoute(
        builder: (context) => const AuthWrapper(),
        settings: const RouteSettings(name: AppRoutes.auth),
      );
    }

    final route = settings.name;
    if (route != null && !RoleBasedNavigation.canAccessRoute(userRole, route)) {
      // Utilisateur n'a pas accès à cette route
      return MaterialPageRoute(
        builder: (context) => _buildAccessDeniedScreen(userRole),
        settings: settings,
      );
    }

    return null; // Laisser passer la navigation normale
  }

  static Widget _buildAccessDeniedScreen(UserRole userRole) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accès Refusé'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Accès Refusé',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous n\'avez pas les permissions nécessaires\npour accéder à cette page.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  final homeRoute = RoleBasedNavigation.getHomeRouteForRole(
                    userRole,
                  );
                  context.pushNamedAndRemoveUntil(homeRoute);
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
