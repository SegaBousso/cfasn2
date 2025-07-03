import 'package:flutter/material.dart';
import 'package:service/models/service_model.dart';
import '../services/services_service.dart';

class ServicesDialogs {
  /// Affiche un dialog de filtres pour les services
  static Future<ServiceFilters?> showFiltersDialog(
    BuildContext context, {
    ServiceFilters? currentFilters,
    List<ServiceCategory>? categories,
  }) async {
    return showModalBottomSheet<ServiceFilters>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FiltersBottomSheet(
        currentFilters: currentFilters ?? ServiceFilters(),
        categories: categories ?? [],
      ),
    );
  }

  /// Affiche un dialog de confirmation pour ajouter aux favoris
  static Future<bool?> showFavoriteConfirmationDialog(
    BuildContext context, {
    required String serviceName,
    required bool isAddingToFavorites,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isAddingToFavorites ? 'Ajouter aux favoris' : 'Retirer des favoris',
        ),
        content: Text(
          isAddingToFavorites
              ? 'Voulez-vous ajouter "$serviceName" à vos favoris ?'
              : 'Voulez-vous retirer "$serviceName" de vos favoris ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isAddingToFavorites ? 'Ajouter' : 'Retirer'),
          ),
        ],
      ),
    );
  }

  /// Affiche un dialog pour trier les services
  static Future<ServiceSortOption?> showSortDialog(
    BuildContext context, {
    ServiceSortOption? currentSort,
  }) async {
    return showDialog<ServiceSortOption>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trier par'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ServiceSortOption.values.map((option) {
            return RadioListTile<ServiceSortOption>(
              title: Text(option.displayName),
              value: option,
              groupValue: currentSort,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  /// Affiche un dialog pour les détails d'un service
  static Future<void> showServiceInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }
}

/// Widget pour le bottom sheet des filtres
class _FiltersBottomSheet extends StatefulWidget {
  final ServiceFilters currentFilters;
  final List<ServiceCategory> categories;

  const _FiltersBottomSheet({
    required this.currentFilters,
    required this.categories,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late ServiceFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Réinitialiser'),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Catégories
          if (widget.categories.isNotEmpty) ...[
            const Text(
              'Catégories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.categories.map((category) {
                return FilterChip(
                  label: Text(category.name),
                  selected: _filters.categoryId == category.id,
                  onSelected: (selected) {
                    setState(() {
                      _filters = _filters.copyWith(
                        categoryId: selected ? category.id : null,
                      );
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Prix
          const Text(
            'Prix (€)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Prix min',
                    border: OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final price = double.tryParse(value);
                    setState(() {
                      _filters = _filters.copyWith(minPrice: price);
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Prix max',
                    border: OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final price = double.tryParse(value);
                    setState(() {
                      _filters = _filters.copyWith(maxPrice: price);
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rating minimum
          const Text(
            'Note minimum',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _filters.minRating ?? 0.0,
            min: 0.0,
            max: 5.0,
            divisions: 10,
            label: (_filters.minRating ?? 0.0).toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(minRating: value);
              });
            },
          ),
          const SizedBox(height: 20),

          // Disponibilité
          SwitchListTile(
            title: const Text('Disponible uniquement'),
            value: _filters.availableOnly ?? false,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(availableOnly: value);
              });
            },
          ),
          const SizedBox(height: 20),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _filters),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _filters = ServiceFilters();
    });
  }
}

/// Classe pour les filtres de services
class ServiceFilters {
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final bool? availableOnly;

  ServiceFilters({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.availableOnly,
  });

  ServiceFilters copyWith({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? availableOnly,
  }) {
    return ServiceFilters(
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }

  bool get hasFilters {
    return categoryId != null ||
        minPrice != null ||
        maxPrice != null ||
        minRating != null ||
        availableOnly != null;
  }
}

/// Options de tri pour les services
enum ServiceSortOption {
  name('Nom A-Z'),
  nameDesc('Nom Z-A'),
  price('Prix croissant'),
  priceDesc('Prix décroissant'),
  rating('Note croissante'),
  ratingDesc('Note décroissante'),
  newest('Plus récents'),
  oldest('Plus anciens');

  const ServiceSortOption(this.displayName);
  final String displayName;
}
