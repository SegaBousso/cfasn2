import 'package:flutter/material.dart';
import '../../../../models/models.dart';

class ServiceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ServiceModel? service;
  final bool isLoading;
  final VoidCallback onSave;

  const ServiceAppBar({
    super.key,
    this.service,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isEditing = service != null;

    return AppBar(
      title: Text(isEditing ? 'Modifier le service' : 'Nouveau service'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      actions: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        else
          TextButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(
              isEditing ? 'Modifier' : 'Créer',
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
