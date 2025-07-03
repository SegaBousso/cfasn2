import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/auth_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/event_bus.dart';
import 'profile_events.dart';
import 'profile_role_handler.dart';

/// Handles saving profile data and related operations
class ProfileSaveHandler {
  final BuildContext context;
  final AuthProvider authProvider;

  ProfileSaveHandler({required this.context, required this.authProvider});

  /// Save the complete profile data
  Future<void> saveProfile(Map<String, dynamic> formData) async {
    try {
      // Emit save started event
      EventBus.instance.emit(ProfileSaveStartedEvent());

      final currentUser = authProvider.user;
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Create updated user
      final updatedUser = currentUser.copyWith(
        firstName: formData['firstName'] as String,
        lastName: formData['lastName'] as String,
        phoneNumber: formData['phoneNumber'] as String,
        address: formData['address'] as String,
        civility: formData['civility'] as String?,
        role: formData['role'] as UserRole,
        displayName: '${formData['firstName']} ${formData['lastName']}',
      );

      // Save to Firestore
      await AuthService().updateUserProfile(updatedUser);

      // Reload user in provider
      await authProvider.reloadUser();

      // Emit success event
      EventBus.instance.emit(
        ProfileSaveSuccessEvent((formData['role'] as UserRole).name),
      );
    } catch (e) {
      // Emit error event
      EventBus.instance.emit(ProfileSaveFailedEvent(e.toString()));
    }
  }

  /// Navigate based on the selected role
  void navigateBasedOnRole(UserRole role) {
    final route = ProfileRoleHandler.getNavigationRoute(role);
    Navigator.pushReplacementNamed(context, route);
  }
}
