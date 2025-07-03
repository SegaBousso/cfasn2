import '../../../../utils/event_bus.dart';
import 'booking_events.dart';

/// Gestionnaire pour les notes et instructions additionnelles de la réservation
class BookingNotesHandler {
  String _notes = '';

  String get notes => _notes;

  /// Met à jour les notes
  void updateNotes(String notes) {
    _notes = notes;

    // Émettre un événement pour informer les widgets de la mise à jour
    EventBus.instance.emit(
      NotesUpdatedEvent(notes: notes, hasNotes: notes.trim().isNotEmpty),
    );
  }

  /// Réinitialise les notes
  void reset() {
    _notes = '';
    EventBus.instance.emit(NotesResetEvent());
  }

  /// Obtient les notes pour la réservation
  String getNotesForBooking() {
    return _notes.trim();
  }

  /// Vérifie si des notes ont été saisies
  bool hasNotes() {
    return _notes.trim().isNotEmpty;
  }

  /// Valide la longueur des notes (optionnel)
  String? validateNotes(String? value) {
    // Les notes sont optionnelles, mais on peut limiter la longueur
    if (value != null && value.length > 500) {
      return 'Les notes ne peuvent pas dépasser 500 caractères';
    }
    return null;
  }
}
