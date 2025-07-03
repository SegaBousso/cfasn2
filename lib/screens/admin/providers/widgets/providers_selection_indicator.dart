import 'package:flutter/material.dart';

/// Indicateur de sélection des prestataires
class ProvidersSelectionIndicator extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onClearSelection;

  const ProvidersSelectionIndicator({
    super.key,
    required this.selectedCount,
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.purple.shade50,
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.purple, size: 20),
          const SizedBox(width: 8),
          Text(
            '$selectedCount prestataire(s) sélectionné(s)',
            style: TextStyle(
              color: Colors.purple.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (onClearSelection != null)
            TextButton(
              onPressed: onClearSelection,
              child: const Text('Tout désélectionner'),
            ),
        ],
      ),
    );
  }
}
