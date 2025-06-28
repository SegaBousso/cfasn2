import 'package:flutter/material.dart';
import '../../../../models/models.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;
  final VoidCallback? onVerify;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.isSelected,
    required this.onTap,
    required this.onSelected,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.purple : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et sélection
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) => onSelected(value ?? false),
                    activeColor: Colors.purple,
                  ),
                  CircleAvatar(
                    backgroundColor: _getAvatarColor(),
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          provider.email,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),

              const SizedBox(height: 12),

              // Informations principales
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.work,
                      'Spécialité',
                      provider.specialty,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.schedule,
                      'Expérience',
                      '${provider.yearsOfExperience} ans',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.star,
                      'Note',
                      '${provider.rating}/5 (${provider.ratingsCount})',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.assignment_turned_in,
                      'Travaux',
                      provider.completedJobs.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Badges et statuts
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (provider.isVerified) _buildBadge('Vérifié', Colors.green),
                  if (provider.isActive)
                    _buildBadge('Actif', Colors.blue)
                  else
                    _buildBadge('Inactif', Colors.grey),
                  if (provider.isAvailable)
                    _buildBadge('Disponible', Colors.orange)
                  else
                    _buildBadge('Indisponible', Colors.red),
                  if (provider.isExperienced)
                    _buildBadge('Expérimenté', Colors.purple),
                  if (provider.isTopRated)
                    _buildBadge('Top Rated', Colors.amber),
                ],
              ),

              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      provider.isActive
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: provider.isActive ? Colors.orange : Colors.green,
                    ),
                    onPressed: onToggleStatus,
                    tooltip: provider.isActive ? 'Désactiver' : 'Activer',
                  ),
                  if (!provider.isVerified && onVerify != null)
                    IconButton(
                      icon: const Icon(Icons.verified, color: Colors.green),
                      onPressed: onVerify,
                      tooltip: 'Vérifier',
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    if (!provider.isActive) {
      color = Colors.grey;
      text = 'Inactif';
    } else if (!provider.isVerified) {
      color = Colors.orange;
      text = 'Non vérifié';
    } else if (!provider.isAvailable) {
      color = Colors.red;
      text = 'Indisponible';
    } else {
      color = Colors.green;
      text = 'Actif';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getAvatarColor() {
    if (!provider.isActive) return Colors.grey;
    if (!provider.isVerified) return Colors.orange;
    if (provider.isTopRated) return Colors.purple;
    return Colors.blue;
  }

  String _getInitials() {
    final words = provider.name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, 2).toUpperCase();
    }
    return 'PR';
  }
}
