import 'dart:async';
import 'services_list_data.dart';
import 'services_list_events.dart';
import '../../../../utils/event_bus.dart';
import '../dialogs/services_dialogs.dart';

/// Handler pour la gestion des filtres et de la recherche
class ServicesListFilterHandler {
  final ServicesListData _data;
  Timer? _searchDebounce;

  ServicesListFilterHandler(this._data);

  /// Gère les changements de recherche avec debouncing
  void handleSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      EventBus.instance.emit(
        SearchAndFilterEvent(
          query: query,
          categoryId: _data.selectedCategoryId,
          filters: _data.currentFilters,
        ),
      );
    });
  }

  /// Change la catégorie sélectionnée
  void handleCategoryChanged(String categoryId) {
    _data.selectedCategoryId = categoryId;
    _data.currentFilters = _data.currentFilters.copyWith(
      categoryId: categoryId,
    );

    EventBus.instance.emit(CategoryChangedEvent(categoryId));
    EventBus.instance.emit(
      SearchAndFilterEvent(
        query: _data.searchController.text,
        categoryId: categoryId,
        filters: _data.currentFilters,
      ),
    );
  }

  /// Applique de nouveaux filtres
  void handleFiltersChanged(ServiceFilters newFilters) {
    _data.currentFilters = newFilters;

    if (newFilters.categoryId != null) {
      _data.selectedCategoryId = newFilters.categoryId!;
    }

    EventBus.instance.emit(FiltersChangedEvent(newFilters));
    EventBus.instance.emit(
      SearchAndFilterEvent(
        query: _data.searchController.text,
        categoryId: _data.selectedCategoryId,
        filters: newFilters,
      ),
    );
  }

  /// Réinitialise les filtres et la recherche
  void handleResetFilters() {
    _data.searchController.clear();
    _data.selectedCategoryId = 'all';
    _data.currentFilters = ServiceFilters();

    EventBus.instance.emit(ResetFiltersEvent());
    EventBus.instance.emit(
      SearchAndFilterEvent(
        query: '',
        categoryId: 'all',
        filters: ServiceFilters(),
      ),
    );
  }

  /// Nettoie les ressources
  void dispose() {
    _searchDebounce?.cancel();
  }
}
