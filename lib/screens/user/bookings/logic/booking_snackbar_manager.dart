import 'package:flutter/material.dart';
import '../../../../utils/event_bus.dart';
import 'booking_events.dart';

/// Gestionnaire pour l'affichage des SnackBars et messages dans l'interface
class BookingSnackBarManager {
  /// Affiche un message de succès
  void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Émettre un événement pour d'autres composants
    EventBus.instance.emit(
      SnackBarShownEvent(type: 'success', message: message),
    );
  }

  /// Affiche un message d'erreur
  void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Émettre un événement pour d'autres composants
    EventBus.instance.emit(SnackBarShownEvent(type: 'error', message: message));
  }

  /// Affiche un message d'information
  void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Émettre un événement pour d'autres composants
    EventBus.instance.emit(SnackBarShownEvent(type: 'info', message: message));
  }

  /// Affiche un message d'avertissement
  void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Émettre un événement pour d'autres composants
    EventBus.instance.emit(
      SnackBarShownEvent(type: 'warning', message: message),
    );
  }

  /// Affiche un message de validation manquante
  void showValidationError(BuildContext context, String field) {
    showError(context, 'Veuillez remplir le champ: $field');
  }

  /// Affiche un message pour une date/heure manquante
  void showDateTimeError(BuildContext context) {
    showError(context, 'Veuillez sélectionner une date et une heure');
  }
}
