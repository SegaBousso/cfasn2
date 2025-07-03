import 'package:flutter/material.dart';

/// Widget pour afficher l'état vide quand aucun prestataire n'est trouvé
class ProvidersEmptyState extends StatelessWidget {
  final VoidCallback onCreateProvider;

  const ProvidersEmptyState({super.key, required this.onCreateProvider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucun prestataire trouvé',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier prestataire',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateProvider,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un prestataire'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
