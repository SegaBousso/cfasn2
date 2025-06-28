import 'package:flutter/material.dart';
import '../providers/admin_provider_manager.dart';
import '../../../models/models.dart';
import 'widgets/provider_card.dart';
import 'widgets/provider_filters.dart';
import 'add_edit_provider_screen.dart';

class ProvidersManagementScreen extends StatefulWidget {
  const ProvidersManagementScreen({super.key});

  @override
  State<ProvidersManagementScreen> createState() =>
      _ProvidersManagementScreenState();
}

class _ProvidersManagementScreenState extends State<ProvidersManagementScreen>
    with SingleTickerProviderStateMixin {
  final AdminProviderManager _providerManager = AdminProviderManager();

  late TabController _tabController;
  List<ProviderModel> _providers = [];
  List<ProviderModel> _filteredProviders = [];
  List<ProviderModel> _selectedProviders = [];

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSpecialty = 'all';

  // Statistiques
  int _totalProvidersCount = 0;
  int _activeProvidersCount = 0;
  int _verifiedProvidersCount = 0;
  int _availableProvidersCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProviders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _providers = await _providerManager.allProviders;
      final stats = await _providerManager.getProviderStats();

      setState(() {
        _totalProvidersCount = stats['total'] ?? 0;
        _activeProvidersCount = stats['active'] ?? 0;
        _verifiedProvidersCount = stats['verified'] ?? 0;
        _availableProvidersCount = stats['available'] ?? 0;
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<ProviderModel> filtered = _providers;

    // Filtrer par onglet
    switch (_tabController.index) {
      case 0: // Tous
        break;
      case 1: // Actifs
        filtered = filtered.where((p) => p.isActive).toList();
        break;
      case 2: // Vérifiés
        filtered = filtered.where((p) => p.isVerified).toList();
        break;
      case 3: // Disponibles
        filtered = filtered.where((p) => p.isAvailable && p.isActive).toList();
        break;
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((provider) {
        return provider.name.toLowerCase().contains(query) ||
            provider.email.toLowerCase().contains(query) ||
            provider.specialty.toLowerCase().contains(query) ||
            provider.specialties.any((s) => s.toLowerCase().contains(query));
      }).toList();
    }

    // Filtrer par spécialité
    if (_selectedSpecialty != 'all') {
      filtered = filtered.where((provider) {
        return provider.specialty == _selectedSpecialty ||
            provider.specialties.contains(_selectedSpecialty);
      }).toList();
    }

    setState(() {
      _filteredProviders = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Prestataires'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading:
            false, // Empêche l'affichage de l'icône de retour
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _applyFilters(),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Tous ($_totalProvidersCount)'),
            Tab(text: 'Actifs ($_activeProvidersCount)'),
            Tab(text: 'Vérifiés ($_verifiedProvidersCount)'),
            Tab(text: 'Disponibles ($_availableProvidersCount)'),
          ],
        ),
        actions: [
          if (_selectedProviders.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _handleBulkActivate,
              tooltip: 'Activer sélectionnés',
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _handleBulkDeactivate,
              tooltip: 'Désactiver sélectionnés',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _handleBulkDelete,
              tooltip: 'Supprimer sélectionnés',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProviders,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques
          _buildStatsCard(),

          // Filtres
          ProviderFilters(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
              _applyFilters();
            },
            onSpecialtyChanged: (specialty) {
              setState(() {
                _selectedSpecialty = specialty;
              });
              _applyFilters();
            },
            selectedProviders: _selectedProviders,
            onClearSelection: () {
              setState(() {
                _selectedProviders.clear();
              });
            },
          ),

          // Liste des prestataires
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProviders.isEmpty
                ? _buildEmptyState()
                : _buildProvidersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProviderDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', _totalProvidersCount, Colors.purple),
          _buildStatItem('Actifs', _activeProvidersCount, Colors.green),
          _buildStatItem('Vérifiés', _verifiedProvidersCount, Colors.blue),
          _buildStatItem(
            'Disponibles',
            _availableProvidersCount,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            onPressed: _showCreateProviderDialog,
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

  Widget _buildProvidersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProviders.length,
      itemBuilder: (context, index) {
        final provider = _filteredProviders[index];
        final isSelected = _selectedProviders.contains(provider);

        return ProviderCard(
          provider: provider,
          isSelected: isSelected,
          onTap: () => _handleProviderTap(provider),
          onSelected: (selected) =>
              _handleProviderSelection(provider, selected),
          onEdit: () => _showEditProviderDialog(provider),
          onDelete: () => _showDeleteConfirmation(provider),
          onToggleStatus: () => _toggleProviderStatus(provider),
          onVerify: () => _verifyProvider(provider),
        );
      },
    );
  }

  void _handleProviderTap(ProviderModel provider) {
    // Afficher les détails du prestataire
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              _showEditProviderDialog(provider);
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
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

  void _handleProviderSelection(ProviderModel provider, bool selected) {
    setState(() {
      if (selected) {
        _selectedProviders.add(provider);
      } else {
        _selectedProviders.remove(provider);
      }
    });
  }

  void _showCreateProviderDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditProviderScreen()),
    ).then((result) {
      if (result != null) {
        _loadProviders();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prestataire créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showEditProviderDialog(ProviderModel provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProviderScreen(provider: provider),
      ),
    ).then((result) {
      if (result != null) {
        _loadProviders();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prestataire modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showDeleteConfirmation(ProviderModel provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le prestataire "${provider.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _providerManager.deleteProvider(provider.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prestataire supprimé'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadProviders();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleProviderStatus(ProviderModel provider) async {
    try {
      await _providerManager.toggleProviderStatus(provider.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Statut modifié: ${!provider.isActive ? "Activé" : "Désactivé"}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadProviders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _verifyProvider(ProviderModel provider) async {
    try {
      await _providerManager.verifyProvider(provider.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prestataire vérifié'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProviders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleBulkActivate() async {
    final providerIds = _selectedProviders.map((p) => p.id).toList();
    try {
      await _providerManager.bulkActivateProviders(providerIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${providerIds.length} prestataire(s) activé(s)'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedProviders.clear();
        });
        _loadProviders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleBulkDeactivate() async {
    final providerIds = _selectedProviders.map((p) => p.id).toList();
    try {
      await _providerManager.bulkDeactivateProviders(providerIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${providerIds.length} prestataire(s) désactivé(s)'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedProviders.clear();
        });
        _loadProviders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleBulkDelete() async {
    final providerIds = _selectedProviders.map((p) => p.id).toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${providerIds.length} prestataire(s) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _providerManager.bulkDeleteProviders(providerIds);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${providerIds.length} prestataire(s) supprimé(s)'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _selectedProviders.clear();
          });
          _loadProviders();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
