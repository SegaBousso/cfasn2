import 'dart:async';
import 'package:flutter/material.dart';
import 'services_list_data.dart';
import 'services_list_events.dart';
import 'services_list_data_handler.dart';
import 'services_list_filter_handler.dart';
import 'services_list_action_handler.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/service_model.dart';

/// Handler principal qui coordonne tous les événements
class ServicesListEventHandler {
  final BuildContext _context;
  final ServicesListData _data;
  final VoidCallback _onStateChanged;

  late final ServicesListDataHandler _dataHandler;
  late final ServicesListFilterHandler _filterHandler;
  late final ServicesListActionHandler _actionHandler;

  StreamSubscription? _eventSubscription;

  ServicesListEventHandler({
    required BuildContext context,
    required ServicesListData data,
    required VoidCallback onStateChanged,
  }) : _context = context,
       _data = data,
       _onStateChanged = onStateChanged {
    _dataHandler = ServicesListDataHandler(_data);
    _filterHandler = ServicesListFilterHandler(_data);
    _actionHandler = ServicesListActionHandler(data: _data, context: _context);
    _setupEventListeners();
  }

  /// Initialise l'écran
  Future<void> initialize() async {
    await _dataHandler.loadInitialData();
    _onStateChanged();
  }

  /// Configure les listeners d'événements
  void _setupEventListeners() {
    _eventSubscription = EventBus.instance.on<ServicesListEvent>().listen((
      event,
    ) {
      _handleEvent(event);
    });
  }

  /// Gère tous les événements
  void _handleEvent(ServicesListEvent event) async {
    switch (event.runtimeType) {
      case LoadInitialDataEvent:
        await _dataHandler.loadInitialData();
        break;

      case SearchAndFilterEvent:
        await _dataHandler.searchAndFilterServices();
        break;

      case ToggleFavoriteEvent:
        final e = event as ToggleFavoriteEvent;
        await _dataHandler.toggleFavorite(e.serviceId);
        break;

      case CategoryChangedEvent:
        // Déjà géré dans le filter handler
        break;

      case FiltersChangedEvent:
        final e = event as FiltersChangedEvent;
        _filterHandler.handleFiltersChanged(e.filters);
        break;

      case ResetFiltersEvent:
        _filterHandler.handleResetFilters();
        break;

      case NavigateToServiceDetailEvent:
        final e = event as NavigateToServiceDetailEvent;
        _actionHandler.handleNavigateToServiceDetail(e.service);
        break;

      case ShowFiltersDialogEvent:
        await _actionHandler.handleShowFiltersDialog();
        break;

      // Événements de réponse
      case ServicesDataLoadedEvent:
      case SearchResultsEvent:
      case LoadingStateChangedEvent:
        _onStateChanged();
        break;

      case FavoriteToggledEvent:
        final e = event as FavoriteToggledEvent;
        final service = _data.services.firstWhere((s) => s.id == e.serviceId);
        _actionHandler.showSuccessMessage(
          e.isNowFavorite
              ? '${service.name} ajouté aux favoris'
              : '${service.name} retiré des favoris',
        );
        _onStateChanged();
        break;

      case ErrorEvent:
        final e = event as ErrorEvent;
        _actionHandler.showErrorMessage(e.message);
        _onStateChanged();
        break;
    }
  }

  // Méthodes publiques pour les widgets
  void handleSearchChanged(String query) =>
      _filterHandler.handleSearchChanged(query);
  void handleCategoryChanged(String categoryId) =>
      _filterHandler.handleCategoryChanged(categoryId);
  void handleToggleFavorite(String serviceId) =>
      EventBus.instance.emit(ToggleFavoriteEvent(serviceId));
  void handleNavigateToServiceDetail(ServiceModel service) =>
      EventBus.instance.emit(NavigateToServiceDetailEvent(service));
  void handleShowFiltersDialog() =>
      EventBus.instance.emit(ShowFiltersDialogEvent());
  void handleResetFilters() => EventBus.instance.emit(ResetFiltersEvent());
  void handleFloatingActionButton() =>
      _actionHandler.handleFloatingActionButton();
  void handleCreateSampleData() => _dataHandler.createSampleDataIfNeeded();

  /// Nettoie les ressources
  void dispose() {
    _eventSubscription?.cancel();
    _filterHandler.dispose();
  }
}
