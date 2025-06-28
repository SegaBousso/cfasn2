import 'package:flutter/material.dart';
import '../../../../models/models.dart';

class ProviderFilters extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onSpecialtyChanged;
  final List<ProviderModel> selectedProviders;
  final VoidCallback onClearSelection;

  const ProviderFilters({
    super.key,
    required this.onSearchChanged,
    required this.onSpecialtyChanged,
    required this.selectedProviders,
    required this.onClearSelection,
  });

  @override
  State<ProviderFilters> createState() => _ProviderFiltersState();
}

class _ProviderFiltersState extends State<ProviderFilters> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = 'all';

  final List<String> _specialties = [
    'all',
    'Nettoyage',
    'Réparation',
    'Éducation',
    'Santé',
    'Beauté',
    'Jardinage',
    'Transport',
    'Informatique',
    'Électricité',
    'Plomberie',
    'Serrurerie',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom, email, spécialité...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                  onChanged: widget.onSearchChanged,
                ),
              ),

              const SizedBox(width: 16),

              // Filtre par spécialité
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  decoration: InputDecoration(
                    labelText: 'Spécialité',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: _specialties.map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Text(
                        specialty == 'all'
                            ? 'Toutes les spécialités'
                            : specialty,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialty = value!;
                    });
                    widget.onSpecialtyChanged(value!);
                  },
                ),
              ),
            ],
          ),

          // Actions de sélection
          if (widget.selectedProviders.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.purple.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.selectedProviders.length} prestataire(s) sélectionné(s)',
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onClearSelection,
                    child: Text(
                      'Désélectionner tout',
                      style: TextStyle(color: Colors.purple.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
