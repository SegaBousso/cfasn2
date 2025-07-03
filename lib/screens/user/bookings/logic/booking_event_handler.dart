import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/booking_service.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../utils/event_bus.dart';
import 'booking_snackbar_manager.dart';
import 'booking_events.dart';

/// Gestionnaire principal des événements pour l'écran de création de réservation
class BookingEventHandler {
  final BookingService _bookingService = BookingService();
  final BookingSnackBarManager _snackBarManager = BookingSnackBarManager();

  /// Fonction de debug pour afficher les réservations
  Future<void> debugViewBookings(BuildContext context) async {
    try {
      print('🔍 Récupération des réservations pour debug...');

      // Obtenir l'utilisateur actuel
      final currentUser = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).user;
      final String userId = currentUser?.uid ?? 'test_user';

      // Récupérer les réservations de l'utilisateur
      final bookings = await _bookingService.getUserBookings(userId);

      print('📋 Nombre de réservations trouvées: ${bookings.length}');

      if (bookings.isEmpty) {
        print('ℹ️  Aucune réservation trouvée pour l\'utilisateur: $userId');
      } else {
        for (int i = 0; i < bookings.length; i++) {
          final booking = bookings[i];
          print('📄 Réservation ${i + 1}:');
          print('   ID: ${booking.id}');
          print('   Service: ${booking.service.name}');
          print('   Date: ${booking.serviceDate}');
          print('   Statut: ${booking.status.label}');
          print('   Montant: ${booking.totalAmount} ${booking.currency}');
          print('   ---');
        }
      }

      _snackBarManager.showInfo(
        context,
        '${bookings.length} réservation(s) trouvée(s) - Voir la console',
      );

      // Émettre un événement avec les données
      EventBus.instance.emit(
        DebugBookingsLoadedEvent(bookings: bookings, userId: userId),
      );
    } catch (e) {
      print('❌ Erreur lors de la récupération des réservations: $e');
      _snackBarManager.showError(context, 'Erreur debug: $e');
    }
  }

  /// Fonction de debug pour créer des providers d'exemple
  Future<void> debugCreateProviders(BuildContext context) async {
    try {
      print('🔧 Création des providers d\'exemple...');

      // TODO: Implémenter la création de providers par défaut si nécessaire
      // Pour l'instant, on simule juste le succès

      _snackBarManager.showSuccess(
        context,
        'Providers d\'exemple créés avec succès!',
      );

      // Émettre un événement
      EventBus.instance.emit(DebugProvidersCreatedEvent());
    } catch (e) {
      print('❌ Erreur lors de la création des providers: $e');
      _snackBarManager.showError(context, 'Erreur création providers: $e');
    }
  }

  /// Gère la validation complète du formulaire
  bool validateBookingForm({
    required GlobalKey<FormState> formKey,
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
    required BuildContext context,
  }) {
    // Validation du formulaire Flutter
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // Validation de la date et heure
    if (selectedDate == null || selectedTime == null) {
      _snackBarManager.showDateTimeError(context);
      return false;
    }

    return true;
  }

  /// Initialise les écouteurs d'événements
  void initializeEventListeners() {
    // Écouter les changements de formulaire pour des validations en temps réel
    EventBus.instance.on<FormDataChangedEvent>().listen((event) {
      _handleFormDataChanged(event.data);
    });

    // Écouter les erreurs de validation
    EventBus.instance.on<ValidationErrorEvent>().listen((event) {
      _handleValidationError(event);
    });
  }

  /// Nettoie les écouteurs d'événements
  void dispose() {
    // Note: Dans cette implémentation simple, on ne garde pas de références aux subscriptions
    // Dans une implémentation plus avancée, il faudrait les stocker et les cancel ici
  }

  /// Gère les changements de données du formulaire
  void _handleFormDataChanged(Map<String, dynamic> data) {
    print('📝 Données du formulaire mises à jour: $data');

    // Ici on pourrait ajouter une logique de validation en temps réel
    // ou de sauvegarde automatique si nécessaire
  }

  /// Gère les erreurs de validation
  void _handleValidationError(ValidationErrorEvent event) {
    print('⚠️ Erreur de validation sur ${event.field}: ${event.message}');
  }
}
