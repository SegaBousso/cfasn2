import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service/providers/auth_provider.dart';
import 'package:service/screens/main_screen.dart';
import 'package:service/screens/admin/admin_main_screen.dart';
import 'package:service/screens/shared/loading_screen.dart';
import 'package:service/screens/auth/login_screen.dart';
import 'package:service/screens/auth/complete_profile_screen.dart';
import '../../models/models.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.status) {
          case AuthStatus.unknown:
          case AuthStatus.loading:
            return const LoadingScreen();
          case AuthStatus.authenticated:
            final user = authProvider.user;
            if (user != null && !user.hasCompleteProfile) {
              // Si le profil n'est pas complet, rediriger vers l'écran de complétion
              return const CompleteProfileScreen();
            }

            // Rediriger vers le bon MainScreen selon le rôle
            if (user != null && user.role == UserRole.admin) {
              return const AdminMainScreen();
            }

            return const MainScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}
