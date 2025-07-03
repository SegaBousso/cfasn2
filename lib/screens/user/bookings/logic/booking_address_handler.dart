import '../../../../utils/event_bus.dart';
import 'booking_events.dart';

/// Gestionnaire pour la sélection et validation de l'adresse d'intervention
class BookingAddressHandler {
  String _selectedAddress = '';

  String get selectedAddress => _selectedAddress;

  /// Valide l'adresse saisie
  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir une adresse';
    }
    if (value.length < 5) {
      return 'L\'adresse doit contenir au moins 5 caractères';
    }
    return null;
  }

  /// Met à jour l'adresse sélectionnée
  void updateAddress(String address) {
    _selectedAddress = address;

    // Émettre un événement pour informer les widgets de la mise à jour
    EventBus.instance.emit(
      AddressUpdatedEvent(
        address: address,
        isValid: validateAddress(address) == null,
      ),
    );
  }

  /// Réinitialise l'adresse
  void reset() {
    _selectedAddress = '';
    EventBus.instance.emit(AddressResetEvent());
  }

  /// Obtient l'adresse actuelle pour la réservation
  String getAddressForBooking() {
    return _selectedAddress.trim();
  }

  /// Vérifie si l'adresse est valide
  bool isAddressValid() {
    return validateAddress(_selectedAddress) == null;
  }
}
