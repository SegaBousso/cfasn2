import 'dart:async';
import 'package:flutter/material.dart';
import 'providers_management_data.dart';
import 'providers_management_events.dart';
import 'providers_management_data_handler.dart';
import 'providers_management_filter_handler.dart';
import 'providers_management_action_handler.dart';
import '../widgets/providers_confirmation_dialogs.dart';
import '../../../../models/models.dart';
import '../../../../utils/event_bus.dart';

/// Handler principal qui coordonne tous les événements
class ProvidersManagementEventHandler {
  final BuildContext _context;
  final ProvidersManagementData _data;
  final VoidCallback _onStateChanged;

  late final ProvidersManagementDataHandler _dataHandler;
  late final ProvidersManagementFilterHandler _filterHandler;
  late final ProvidersManagementActionHandler _actionHandler;

  StreamSubscription? _eventSubscription;

  ProvidersManagementEventHandler({
    required BuildContext context,
    required ProvidersManagementData data,
    required VoidCallback onStateChanged,
  }) : _context = context,
       _data = data,
       _onStateChanged = onStateChanged {
    _dataHandler = ProvidersManagementDataHandler(_data);
    _filterHandler = ProvidersManagementFilterHandler(_data);
    _actionHandler = ProvidersManagementActionHandler(
      data: _data,
      context: _context,
    );
    _setupEventListeners();
  }

  /// Initialise l'écran
  Future<void> initialize() async {
    await _dataHandler.loadProviders();
    _filterHandler.applyFilters();
    _onStateChanged();
  }

  /// Configure les listeners d'événements
  void _setupEventListeners() {
    _eventSubscription = EventBus.instance
        .on<ProvidersManagementEvent>()
        .listen((event) {
          _handleEvent(event);
        });
  }

  /// Gère tous les événements
  void _handleEvent(ProvidersManagementEvent event) async {
    switch (event.runtimeType) {
      case LoadProvidersEvent:
        await _dataHandler.loadProviders();
        _filterHandler.applyFilters();
        break;

      case TabChangedEvent:
        final e = event as TabChangedEvent;
        _filterHandler.handleTabChanged(e.tabIndex);
        break;

      case SearchChangedEvent:
        final e = event as SearchChangedEvent;
        _filterHandler.handleSearchChanged(e.query);
        break;

      case SpecialtyChangedEvent:
        final e = event as SpecialtyChangedEvent;
        _filterHandler.handleSpecialtyChanged(e.specialty);
        break;

      case ProviderSelectionToggleEvent:
        final e = event as ProviderSelectionToggleEvent;
        _actionHandler.handleProviderSelectionToggle(e.provider);
        break;

      case ClearSelectionEvent:
        _actionHandler.handleClearSelection();
        break;

      case NavigateToCreateProviderEvent:
        await _actionHandler.handleNavigateToCreateProvider();
        break;

      case NavigateToEditProviderEvent:
        final e = event as NavigateToEditProviderEvent;
        await _actionHandler.handleNavigateToEditProvider(e.provider);
        break;

      // Actions individuelles
      case ActivateProviderEvent:
        final e = event as ActivateProviderEvent;
        await _dataHandler.activateProvider(e.provider);
        break;

      case DeactivateProviderEvent:
        final e = event as DeactivateProviderEvent;
        await _dataHandler.deactivateProvider(e.provider);
        break;

      case DeleteProviderEvent:
        final e = event as DeleteProviderEvent;
        await _dataHandler.deleteProvider(e.provider);
        break;

      case VerifyProviderEvent:
        final e = event as VerifyProviderEvent;
        await _dataHandler.verifyProvider(e.provider);
        break;

      // Actions bulk
      case BulkActivateEvent:
        final e = event as BulkActivateEvent;
        await _dataHandler.bulkActivateProviders(e.providers);
        break;

      case BulkDeactivateEvent:
        final e = event as BulkDeactivateEvent;
        await _dataHandler.bulkDeactivateProviders(e.providers);
        break;

      case BulkDeleteEvent:
        final e = event as BulkDeleteEvent;
        await _dataHandler.bulkDeleteProviders(e.providers);
        break;

      // Événements de réponse
      case ProvidersLoadedEvent:
      case FiltersAppliedEvent:
      case LoadingStateChangedEvent:
        _onStateChanged();
        break;

      case ProviderActionCompletedEvent:
        final e = event as ProviderActionCompletedEvent;
        _actionHandler.showMessage(e.message, isSuccess: e.isSuccess);
        _onStateChanged();
        break;

      case ErrorEvent:
        final e = event as ErrorEvent;
        _actionHandler.showMessage(e.message, isSuccess: false);
        _onStateChanged();
        break;
    }
  }

  // Méthodes publiques pour les widgets
  void handleRefresh() => EventBus.instance.emit(LoadProvidersEvent());
  void handleTabChanged(int index) => _filterHandler.handleTabChanged(index);
  void handleSearchChanged(String query) =>
      _filterHandler.handleSearchChanged(query);
  void handleSpecialtyChanged(String specialty) =>
      _filterHandler.handleSpecialtyChanged(specialty);
  void handleProviderSelection(ProviderModel provider, bool selected) =>
      _actionHandler.handleProviderSelection(provider, selected);
  void handleToggleProviderStatus(ProviderModel provider) =>
      _actionHandler.handleToggleProviderStatus(provider);
  void handleProviderSelectionToggle(ProviderModel provider) =>
      _actionHandler.handleProviderSelectionToggle(provider);
  void handleClearSelection() => _actionHandler.handleClearSelection();
  void handleCreateProvider() =>
      _actionHandler.handleNavigateToCreateProvider();
  void handleEditProvider(ProviderModel provider) =>
      _actionHandler.handleNavigateToEditProvider(provider);
  void handleActivateProvider(ProviderModel provider) =>
      _actionHandler.handleActivateProvider(provider);
  void handleDeactivateProvider(ProviderModel provider) =>
      _actionHandler.handleDeactivateProvider(provider);
  void handleDeleteProvider(ProviderModel provider) =>
      _actionHandler.handleDeleteProvider(provider);
  void handleVerifyProvider(ProviderModel provider) =>
      _actionHandler.handleVerifyProvider(provider);
  void handleBulkActivate() => _actionHandler.handleBulkActivate();
  void handleBulkDeactivate() => _actionHandler.handleBulkDeactivate();
  void handleBulkDelete() async {
    final count = _data.selectedProviders.length;
    final confirmed =
        await ProvidersConfirmationDialogs.showBulkDeleteConfirmation(
          _context,
          count,
        );

    if (confirmed == true) {
      _actionHandler.handleBulkDelete();
    }
  }

  /// Nettoie les ressources
  void dispose() {
    _eventSubscription?.cancel();
  }
}
