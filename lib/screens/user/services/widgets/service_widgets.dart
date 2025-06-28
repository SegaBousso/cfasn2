import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';

/// Widget pour afficher une carte de service
class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;
  final bool showProvider;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
    this.showProvider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image du service
                  ServiceImage(
                    imageUrl: service.imageUrl ?? service.imagePath,
                    size: 80,
                  ),
                  const SizedBox(width: 16),

                  // Informations du service
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
                          service.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Rating et reviews
                        ServiceRating(
                          rating: service.rating,
                          totalReviews: service.totalReviews,
                        ),

                        if (showProvider && service.providerName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Par ${service.providerName}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions
                  Column(
                    children: [
                      if (onFavoriteToggle != null)
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: onFavoriteToggle,
                        ),
                      ServicePrice(
                        price: service.price,
                        currency: service.currency,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Informations supplémentaires
              Row(
                children: [
                  if (service.estimatedDuration != null) ...[
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      service.estimatedDuration!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                  ],
                  ServiceAvailability(isAvailable: service.isAvailable),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget pour afficher l'image d'un service
class ServiceImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final IconData defaultIcon;

  const ServiceImage({
    super.key,
    this.imageUrl,
    this.size = 80,
    this.defaultIcon = Icons.build,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    defaultIcon,
                    size: size * 0.5,
                    color: Colors.grey,
                  );
                },
              ),
            )
          : Icon(defaultIcon, size: size * 0.5, color: Colors.grey),
    );
  }
}

/// Widget pour afficher le rating d'un service
class ServiceRating extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double iconSize;

  const ServiceRating({
    super.key,
    required this.rating,
    required this.totalReviews,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: iconSize),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Text(
          '($totalReviews avis)',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

/// Widget pour afficher le prix d'un service
class ServicePrice extends StatelessWidget {
  final double price;
  final String currency;
  final String? unit;

  const ServicePrice({
    super.key,
    required this.price,
    this.currency = 'EUR',
    this.unit = '/h',
  });

  @override
  Widget build(BuildContext context) {
    final symbol = currency == 'EUR' ? '€' : currency;
    return Text(
      '${price.toStringAsFixed(0)}$symbol${unit ?? ''}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }
}

/// Widget pour afficher la disponibilité d'un service
class ServiceAvailability extends StatelessWidget {
  final bool isAvailable;

  const ServiceAvailability({super.key, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isAvailable ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: isAvailable ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          isAvailable ? 'Disponible' : 'Non disponible',
          style: TextStyle(
            color: isAvailable ? Colors.green : Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Widget pour un chip de filtre de catégorie
class CategoryFilterChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? selectedColor;

  const CategoryFilterChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) => onTap(),
        backgroundColor:
            backgroundColor ?? Colors.white.withValues(alpha: 0.15),
        selectedColor: selectedColor ?? Colors.white,
        checkmarkColor: Colors.deepPurple,
        side: BorderSide(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.black54,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
        elevation: isSelected ? 2 : 0,
        pressElevation: 4,
      ),
    );
  }
}

/// Widget pour l'état vide de la liste de services
class ServicesEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onReset;
  final IconData icon;

  const ServicesEmptyState({
    super.key,
    this.title = 'Aucun service trouvé',
    this.subtitle = 'Essayez de modifier vos critères de recherche',
    this.onReset,
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              if (onReset != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réinitialiser'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget pour une barre de recherche personnalisée
class ServiceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const ServiceSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Rechercher un service...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
