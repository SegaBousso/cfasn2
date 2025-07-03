import 'package:flutter/material.dart';
import 'providers_management_data.dart';
import 'providers_management_events.dart';
import '../add_edit_provider_screen.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/models.dart';

/// Handler pour les actions utilisateur
class ProvidersManagementActionHandler {
  final ProvidersManagementData _data;
  final BuildContext _context;

  ProvidersManagementActionHandler({
    required ProvidersManagementData data,
    required BuildContext context,
  }) : _data = data,
       _context = context;

  /// Gère la sélection/désélection d'un prestataire
  void handleProviderSelection(ProviderModel provider, bool selected) {
    if (selected) {
      _data.addToSelection(provider);
    } else {
      _data.removeFromSelection(provider);
    }
    EventBus.instance.emit(ProviderSelectionToggleEvent(provider));
  }

  /// Gère la sélection/désélection d'un prestataire (toggle)
  void handleProviderSelectionToggle(ProviderModel provider) {
    _data.toggleSelection(provider);
    EventBus.instance.emit(ProviderSelectionToggleEvent(provider));
  }

  /// Nettoie la sélection
  void handleClearSelection() {
    _data.clearSelection();
    EventBus.instance.emit(ClearSelectionEvent());
  }

  /// Navigue vers l'écran de création d'un prestataire
  Future<void> handleNavigateToCreateProvider() async {
    EventBus.instance.emit(NavigateToCreateProviderEvent());

    final result = await Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => const AddEditProviderScreen()),
    );

    if (result != null) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Prestataire créé avec succès',
          isSuccess: true,
        ),
      );
      EventBus.instance.emit(LoadProvidersEvent());
    }
  }

  /// Navigue vers l'écran d'édition d'un prestataire
  Future<void> handleNavigateToEditProvider(ProviderModel provider) async {
    EventBus.instance.emit(NavigateToEditProviderEvent(provider));

    final result = await Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => AddEditProviderScreen(provider: provider),
      ),
    );

    if (result != null) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Prestataire modifié avec succès',
          isSuccess: true,
        ),
      );
      EventBus.instance.emit(LoadProvidersEvent());
    }
  }

  /// Gère les actions individuelles
  void handleActivateProvider(ProviderModel provider) {
    EventBus.instance.emit(ActivateProviderEvent(provider));
  }

  void handleDeactivateProvider(ProviderModel provider) {
    EventBus.instance.emit(DeactivateProviderEvent(provider));
  }

  void handleToggleProviderStatus(ProviderModel provider) {
    if (provider.isActive) {
      EventBus.instance.emit(DeactivateProviderEvent(provider));
    } else {
      EventBus.instance.emit(ActivateProviderEvent(provider));
    }
  }

  void handleVerifyProvider(ProviderModel provider) {
    EventBus.instance.emit(VerifyProviderEvent(provider));
  }

  /// Gère la suppression d'un prestataire avec confirmation
  Future<void> handleDeleteProvider(ProviderModel provider) async {
    final confirmed = await _showDeleteConfirmationDialog(provider.name);
    if (confirmed) {
      EventBus.instance.emit(DeleteProviderEvent(provider));
    }
  }

  /// Gère les actions bulk avec confirmation
  Future<void> handleBulkActivate() async {
    if (_data.selectedProviders.isEmpty) return;

    final confirmed = await _showBulkActionConfirmationDialog(
      'activer',
      _data.selectedProviders.length,
    );

    if (confirmed) {
      EventBus.instance.emit(
        BulkActivateEvent(List.from(_data.selectedProviders)),
      );
    }
  }

  Future<void> handleBulkDeactivate() async {
    if (_data.selectedProviders.isEmpty) return;

    final confirmed = await _showBulkActionConfirmationDialog(
      'désactiver',
      _data.selectedProviders.length,
    );

    if (confirmed) {
      EventBus.instance.emit(
        BulkDeactivateEvent(List.from(_data.selectedProviders)),
      );
    }
  }

  Future<void> handleBulkDelete() async {
    if (_data.selectedProviders.isEmpty) return;

    final confirmed = await _showBulkActionConfirmationDialog(
      'supprimer',
      _data.selectedProviders.length,
    );

    if (confirmed) {
      EventBus.instance.emit(
        BulkDeleteEvent(List.from(_data.selectedProviders)),
      );
    }
  }

  /// Affiche un dialog de confirmation pour la suppression
  Future<bool> _showDeleteConfirmationDialog(String providerName) async {
    return await showDialog<bool>(
          context: _context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer "$providerName" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Affiche un dialog de confirmation pour les actions bulk
  Future<bool> _showBulkActionConfirmationDialog(
    String action,
    int count,
  ) async {
    return await showDialog<bool>(
          context: _context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer l\'action'),
            content: Text(
              'Êtes-vous sûr de vouloir $action $count prestataire(s) ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: action == 'supprimer'
                      ? Colors.red
                      : Colors.purple,
                ),
                child: Text(action == 'supprimer' ? 'Supprimer' : 'Confirmer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Affiche un message dans une SnackBar
  void showMessage(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: isSuccess ? 2 : 3),
      ),
    );
  }
}
