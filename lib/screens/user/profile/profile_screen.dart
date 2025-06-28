import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/overflow_safe_widgets.dart';
import 'sections/profile_header_section.dart';
import 'sections/profile_stats_section.dart';
import 'sections/profile_menu_section.dart';
import 'dialogs/profile_dialogs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        // Si aucun utilisateur connecté, rediriger vers l'authentification
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/auth');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon Profil'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
              ),
            ],
          ),
          body: ResponsiveBuilder(
            builder: (context, dimensions) {
              return OverflowSafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProfileHeaderSection(
                        user: user,
                        onChangeProfilePicture: () => _changeProfilePicture(),
                      ),
                      ProfileStatsSection(user: user),
                      ProfileMenuSection(parentContext: context),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Gère le changement de photo de profil
  void _changeProfilePicture() {
    ProfileDialogs.showChangeProfilePictureDialog(context);
  }
}
