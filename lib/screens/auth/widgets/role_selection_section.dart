import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../widgets/overflow_safe_widgets.dart';
import '../logic/profile_role_handler.dart';

/// Role selection section widget
class RoleSelectionSection extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleSelectionSection({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveText(
          'Je suis :',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: ProfileRoleHandler.getAvailableRoles().map((role) {
              return RadioListTile<UserRole>(
                title: Text(role.label),
                subtitle: Text(ProfileRoleHandler.getRoleDescription(role)),
                value: role,
                groupValue: selectedRole,
                onChanged: (UserRole? value) {
                  if (value != null) {
                    onRoleChanged(value);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
