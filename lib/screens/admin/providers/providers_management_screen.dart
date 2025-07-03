import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'add_edit_provider_screen.dart';

// Logic Handlers
import 'logic/providers_management_data.dart';
import 'logic/providers_management_event_handler.dart';

// Modular Widgets
import 'widgets/providers_app_bar.dart';
import 'widgets/providers_stats_section.dart';
import 'widgets/provider_filters.dart';
import 'widgets/providers_list_view.dart';
import 'widgets/providers_empty_state.dart';
import 'widgets/provider_details_dialog.dart';
import 'widgets/providers_confirmation_dialogs.dart';

class ProvidersManagementScreen extends StatefulWidget {
  const ProvidersManagementScreen({super.key});

  @override
  State<ProvidersManagementScreen> createState() =>
      _ProvidersManagementScreenState();
}

class _ProvidersManagementScreenState extends State<ProvidersManagementScreen>
    with SingleTickerProviderStateMixin {
  late final ProvidersManagementData _data;
  late final ProvidersManagementEventHandler _eventHandler;

  @override
  void initState() {
    super.initState();
    _initializeHandlers();
    _eventHandler.initialize();
  }

  /// Initialise les handlers de logique métier
  void _initializeHandlers() {
    _data = ProvidersManagementData();
    _data.initializeTabController(this);

    _eventHandler = ProvidersManagementEventHandler(
      context: context,
      data: _data,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _data.dispose();
    _eventHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProvidersAppBar(
        tabController: _data.tabController,
        totalCount: _data.totalProvidersCount,
        activeCount: _data.activeProvidersCount,
        verifiedCount: _data.verifiedProvidersCount,
        availableCount: _data.availableProvidersCount,
        hasSelection: _data.selectedProviders.isNotEmpty,
        onTabChanged: _eventHandler.handleTabChanged,
        onRefresh: _eventHandler.handleRefresh,
        onBulkActivate: _eventHandler.handleBulkActivate,
        onBulkDeactivate: _eventHandler.handleBulkDeactivate,
        onBulkDelete: _eventHandler.handleBulkDelete,
      ),
      body: Column(
        children: [
          // Statistiques
          ProvidersStatsSection(
            totalCount: _data.totalProvidersCount,
            activeCount: _data.activeProvidersCount,
            verifiedCount: _data.verifiedProvidersCount,
            availableCount: _data.availableProvidersCount,
          ),

          // Filtres
          ProviderFilters(
            onSearchChanged: _eventHandler.handleSearchChanged,
            onSpecialtyChanged: _eventHandler.handleSpecialtyChanged,
            selectedProviders: _data.selectedProviders,
            onClearSelection: _eventHandler.handleClearSelection,
          ),

          // Liste des prestataires
          Expanded(
            child: _data.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _data.filteredProviders.isEmpty
                ? ProvidersEmptyState(onCreateProvider: _handleCreateProvider)
                : ProvidersListView(
                    providers: _data.filteredProviders,
                    selectedProviders: _data.selectedProviders,
                    isLoading: _data.isLoading,
                    onProviderTap: _handleProviderTap,
                    onProviderSelectionToggle: (provider) =>
                        _eventHandler.handleProviderSelection(
                          provider,
                          !_data.selectedProviders.contains(provider),
                        ),
                    onEdit: _handleEditProvider,
                    onDelete: _handleDeleteProvider,
                    onToggleStatus: _eventHandler.handleToggleProviderStatus,
                    onVerify: _eventHandler.handleVerifyProvider,
                    onRefresh: _eventHandler.handleRefresh,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "providers_management_fab",
        onPressed: _handleCreateProvider,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Navigation vers la création d'un prestataire
  void _handleCreateProvider() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditProviderScreen()),
    ).then((result) {
      if (result != null) {
        _eventHandler.handleRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prestataire créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  /// Navigation vers l'édition d'un prestataire
  void _handleEditProvider(ProviderModel provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProviderScreen(provider: provider),
      ),
    ).then((result) {
      if (result != null) {
        _eventHandler.handleRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prestataire modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  /// Affichage des détails d'un prestataire
  void _handleProviderTap(ProviderModel provider) {
    showDialog(
      context: context,
      builder: (context) => ProviderDetailsDialog(
        provider: provider,
        onEdit: () => _handleEditProvider(provider),
      ),
    );
  }

  /// Gestion de la suppression d'un prestataire
  void _handleDeleteProvider(ProviderModel provider) async {
    final confirmed = await ProvidersConfirmationDialogs.showDeleteConfirmation(
      context,
      provider,
    );

    if (confirmed == true) {
      _eventHandler.handleDeleteProvider(provider);
    }
  }
}
