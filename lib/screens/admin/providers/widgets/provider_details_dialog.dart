import 'package:flutter/material.dart';
import '../../../../models/models.dart';

/// Widget pour afficher les détails d'un prestataire dans une boîte de dialogue
class ProviderDetailsDialog extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onEdit;

  const ProviderDetailsDialog({
    super.key,
    required this.provider,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(provider.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Email', provider.email),
            _buildDetailRow('Téléphone', provider.phoneNumber),
            _buildDetailRow('Adresse', provider.address),
            _buildDetailRow('Spécialité', provider.specialty),
            _buildDetailRow(
              'Expérience',
              '${provider.yearsOfExperience} années',
            ),
            _buildDetailRow(
              'Note',
              '${provider.rating}/5 (${provider.ratingsCount} avis)',
            ),
            _buildDetailRow(
              'Travaux réalisés',
              provider.completedJobs.toString(),
            ),
            _buildDetailRow('Statut', provider.statusText),
            if (provider.specialties.isNotEmpty)
              _buildDetailRow('Spécialités', provider.specialties.join(', ')),
            if (provider.workingAreas.isNotEmpty)
              _buildDetailRow('Zones', provider.workingAreas.join(', ')),
            if (provider.certifications.isNotEmpty)
              _buildDetailRow(
                'Certifications',
                provider.certifications.join(', '),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onEdit();
          },
          child: const Text('Modifier'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
