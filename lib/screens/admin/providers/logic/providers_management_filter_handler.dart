import 'providers_management_data.dart';
import 'providers_management_events.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/models.dart';

/// Handler pour la gestion des filtres et de la recherche
class ProvidersManagementFilterHandler {
  final ProvidersManagementData _data;

  ProvidersManagementFilterHandler(this._data);

  /// Applique les filtres selon l'onglet actuel
  void applyFilters() {
    List<ProviderModel> filtered = _data.providers;

    // Filtrer par onglet
    switch (_data.tabController.index) {
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
    if (_data.searchQuery.isNotEmpty) {
      final query = _data.searchQuery.toLowerCase();
      filtered = filtered.where((provider) {
        return provider.name.toLowerCase().contains(query) ||
            provider.email.toLowerCase().contains(query) ||
            provider.specialty.toLowerCase().contains(query) ||
            provider.specialties.any((s) => s.toLowerCase().contains(query));
      }).toList();
    }

    // Filtrer par spécialité
    if (_data.selectedSpecialty != 'all') {
      filtered = filtered.where((provider) {
        return provider.specialty == _data.selectedSpecialty ||
            provider.specialties.contains(_data.selectedSpecialty);
      }).toList();
    }

    _data.filteredProviders = filtered;

    EventBus.instance.emit(FiltersAppliedEvent(filtered));
  }

  /// Gère le changement d'onglet
  void handleTabChanged(int tabIndex) {
    EventBus.instance.emit(TabChangedEvent(tabIndex));
    applyFilters();
  }

  /// Gère le changement de recherche
  void handleSearchChanged(String query) {
    _data.searchQuery = query;
    EventBus.instance.emit(SearchChangedEvent(query));
    applyFilters();
  }

  /// Gère le changement de spécialité
  void handleSpecialtyChanged(String specialty) {
    _data.selectedSpecialty = specialty;
    EventBus.instance.emit(SpecialtyChangedEvent(specialty));
    applyFilters();
  }

  /// Réinitialise tous les filtres
  void resetFilters() {
    _data.searchQuery = '';
    _data.selectedSpecialty = 'all';
    _data.tabController.animateTo(0);
    applyFilters();
  }
}
