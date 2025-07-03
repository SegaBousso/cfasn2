import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/models.dart';
import '../../../../services/booking_service.dart';
import '../../../../providers/auth_provider.dart';
import '../../../admin/providers/admin_provider_manager.dart';
import '../../../../utils/event_bus.dart';
import 'booking_form_data.dart';
import 'booking_events.dart';

/// Gestionnaire pour la soumission et la sauvegarde des réservations
class BookingSaveHandler {
  final BookingService _bookingService = BookingService();
  final AdminProviderManager _adminProviderManager = AdminProviderManager();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Soumet une nouvelle réservation
  Future<BookingModel?> submitBooking({
    required BuildContext context,
    required ServiceModel service,
    required BookingFormData formData,
  }) async {
    // Valider les données du formulaire
    if (!_validateFormData(formData)) {
      _showErrorSnackBar(
        context,
        'Veuillez remplir tous les champs obligatoires',
      );
      return null;
    }

    _setLoading(true);

    try {
      print('🚀 Début de la création de réservation...');

      // Obtenir l'utilisateur actuel
      final currentUser = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).user;
      final String userId =
          currentUser?.uid ??
          'test_user_${DateTime.now().millisecondsSinceEpoch}';
      final String userName = currentUser?.displayName ?? 'Utilisateur Test';
      final String userEmail = currentUser?.email ?? 'test@example.com';

      // Enrichir les informations du provider
      String? providerName;
      if (service.providerId != null) {
        try {
          final provider = await _adminProviderManager.getProviderById(
            service.providerId!,
          );
          providerName = provider?.name;
          print('🏪 Provider trouvé: $providerName');
        } catch (e) {
          print('⚠️  Impossible de récupérer les infos du provider: $e');
        }
      }

      // Créer le modèle de réservation
      final booking = _createBookingModel(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userPhone: currentUser?.phoneNumber,
        service: service,
        formData: formData,
        providerName: providerName,
      );

      print('📋 Données de réservation créées: ${booking.id}');
      print('👤 Utilisateur: $userName ($userId)');
      print('🛠️ Service: ${service.name} (${service.id})');
      print('🏪 Service Provider ID: ${service.providerId}');
      print('👨‍� Provider Name: $providerName');
      print('�📅 Date: ${booking.serviceDate}');
      print('💰 Montant: ${booking.totalAmount} ${booking.currency}');

      // Appeler le service de réservation
      final bookingId = await _bookingService.createBookingWithTransaction(
        booking,
        sendNotification: true,
        processPayment: false, // Le paiement sera traité séparément
      );

      if (bookingId != null && context.mounted) {
        print('✅ Réservation créée avec succès: $bookingId');
        _showSuccessSnackBar(context, 'Réservation créée avec succès !');
        return booking;
      } else {
        throw Exception('Impossible de créer la réservation');
      }
    } catch (e) {
      print('❌ Erreur lors de la création de réservation: $e');
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Erreur lors de la création: ${e.toString()}',
        );
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Valide les données du formulaire
  bool _validateFormData(BookingFormData formData) {
    return formData.selectedDate != null &&
        formData.selectedTime != null &&
        formData.selectedAddress.isNotEmpty;
  }

  /// Crée le modèle de réservation
  BookingModel _createBookingModel({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    required ServiceModel service,
    required BookingFormData formData,
    String? providerName,
  }) {
    return BookingModel(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      userAddress: formData.selectedAddress.isNotEmpty
          ? formData.selectedAddress
          : null,
      bookingDate: DateTime.now(),
      serviceDate: DateTime(
        formData.selectedDate!.year,
        formData.selectedDate!.month,
        formData.selectedDate!.day,
        formData.selectedTime!.hour,
        formData.selectedTime!.minute,
      ),
      service: service,
      status: BookingStatus.pending,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: 'card',
      serviceDescription: service.description,
      additionalDetails: formData.notes,
      totalAmount: service.price,
      currency: service.currency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      providerId: service.providerId?.isNotEmpty == true
          ? service.providerId
          : null,
      providerName: providerName?.isNotEmpty == true ? providerName : null,
      metadata: {
        'source': 'mobile_app',
        'serviceCategory': service.categoryId,
        'bookingMethod': 'instant',
      },
    );
  }

  /// Met à jour l'état de chargement
  void _setLoading(bool loading) {
    _isLoading = loading;
    EventBus.instance.emit(BookingLoadingChangedEvent(isLoading: loading));
  }

  /// Affiche un message de succès
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche un message d'erreur
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
