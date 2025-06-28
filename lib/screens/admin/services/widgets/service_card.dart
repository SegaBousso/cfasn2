import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../utils/responsive_helper.dart';
import '../../../../widgets/overflow_safe_widgets.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onViewDetails;

  const ServiceCard({
    super.key,
    required this.service,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et statut
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.categoryName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                _buildStatusChips(),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              service.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Prix et évaluation
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${service.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (service.totalReviews > 0) ...[
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${service.rating.toStringAsFixed(1)} (${service.totalReviews})',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ] else
                  Text(
                    'Nouveau service',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Tags
            if (service.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: service.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Informations de date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Créé le ${_formatDate(service.createdAt)}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      Text(
                        'Modifié le ${_formatDate(service.updatedAt)}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Statut actif/inactif
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: service.isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            service.isActive ? 'Actif' : 'Inactif',
            style: TextStyle(
              color: service.isActive ? Colors.green : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Statut disponible/indisponible
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: service.isAvailable
                ? Colors.blue.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            service.isAvailable ? 'Disponible' : 'Indisponible',
            style: TextStyle(
              color: service.isAvailable ? Colors.blue : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onViewDetails != null)
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: onViewDetails,
            tooltip: 'Voir les détails',
            iconSize: 20,
            color: Colors.blue,
          ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
            tooltip: 'Modifier',
            iconSize: 20,
            color: Colors.orange,
          ),
        if (onToggleStatus != null)
          IconButton(
            icon: Icon(service.isActive ? Icons.pause : Icons.play_arrow),
            onPressed: onToggleStatus,
            tooltip: service.isActive ? 'Désactiver' : 'Activer',
            iconSize: 20,
            color: service.isActive ? Colors.orange : Colors.green,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Supprimer',
            iconSize: 20,
            color: Colors.red,
          ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le service "${service.name}" ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class ServiceStats extends StatelessWidget {
  final int totalServices;
  final int activeServices;
  final int availableServices;
  final double averageRating;

  const ServiceStats({
    super.key,
    required this.totalServices,
    required this.activeServices,
    required this.availableServices,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveContainer(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AdaptiveText(
            'Statistiques des services',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          ResponsiveBuilder(
            builder: (context, dimensions) {
              if (dimensions.isDesktop) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Total',
                        totalServices.toString(),
                        Icons.business_center,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Actifs',
                        activeServices.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Disponibles',
                        availableServices.toString(),
                        Icons.schedule,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Note moy.',
                        averageRating.toStringAsFixed(1),
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Total',
                            totalServices.toString(),
                            Icons.business_center,
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Actifs',
                            activeServices.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getSpacing(context) * 0.5,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Disponibles',
                            availableServices.toString(),
                            Icons.schedule,
                            Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Note moy.',
                            averageRating.toStringAsFixed(1),
                            Icons.star,
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AdaptiveContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdaptiveContainer(
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context) * 0.5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context) * 0.25),
          AdaptiveText(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context) * 0.125),
          AdaptiveText(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.getFontSize(context),
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
