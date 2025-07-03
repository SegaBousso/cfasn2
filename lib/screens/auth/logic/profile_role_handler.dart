import '../../../models/models.dart';

/// Handles role-related logic for the complete profile screen
class ProfileRoleHandler {
  /// Get user roles available for selection (excluding admin)
  static List<UserRole> getAvailableRoles() {
    return UserRole.values.where((role) => role != UserRole.admin).toList();
  }

  /// Get description for a specific role
  static String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.client:
        return 'Je souhaite réserver des services';
      case UserRole.provider:
        return 'Je veux proposer mes services';
      case UserRole.admin:
        return 'Administrateur';
    }
  }

  /// Get navigation route based on role
  static String getNavigationRoute(UserRole role) {
    switch (role) {
      case UserRole.client:
        return '/user/home';
      case UserRole.provider:
        return '/provider/dashboard';
      case UserRole.admin:
        return '/admin/dashboard';
    }
  }
}
