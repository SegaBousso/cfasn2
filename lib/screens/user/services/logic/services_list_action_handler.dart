import 'package:flutter/material.dart';
import 'services_list_data.dart';
import 'services_list_events.dart';
import '../service_detail_screen.dart';
import '../dialogs/services_dialogs.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/service_model.dart';

/// Handler pour les actions utilisateur
class ServicesListActionHandler {
  final ServicesListData _data;
  final BuildContext _context;

  ServicesListActionHandler({
    required ServicesListData data,
    required BuildContext context,
  }) : _data = data,
       _context = context;

  /// Navigue vers les détails d'un service
  void handleNavigateToServiceDetail(ServiceModel service) {
    EventBus.instance.emit(NavigateToServiceDetailEvent(service));

    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }

  /// Affiche le dialog des filtres
  Future<void> handleShowFiltersDialog() async {
    EventBus.instance.emit(ShowFiltersDialogEvent());

    final newFilters = await ServicesDialogs.showFiltersDialog(
      _context,
      currentFilters: _data.currentFilters,
      categories: _data.categories.where((c) => c.id != 'all').toList(),
    );

    if (newFilters != null) {
      EventBus.instance.emit(FiltersChangedEvent(newFilters));
    }
  }

  /// Gère le FAB (création de données d'exemple ou demande de service)
  Future<void> handleFloatingActionButton() async {
    // Debug: Create sample data if needed
    if (_data.categories.length <= 1 || _data.services.isEmpty) {
      try {
        _showSnackBar('Création des données de test...', isSuccess: true);
        EventBus.instance.emit(LoadInitialDataEvent());
        _showSnackBar('Données créées avec succès!', isSuccess: true);
      } catch (e) {
        _showSnackBar('Erreur: $e', isSuccess: false);
      }
    } else {
      _showSnackBar(
        'Fonctionnalité de demande de service à venir',
        isSuccess: true,
      );
    }
  }

  /// Affiche un message dans une SnackBar
  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: isSuccess ? 2 : 3),
      ),
    );
  }

  /// Affiche un message d'erreur
  void showErrorMessage(String message) {
    _showSnackBar(message, isSuccess: false);
  }

  /// Affiche un message de succès
  void showSuccessMessage(String message) {
    _showSnackBar(message, isSuccess: true);
  }
}
