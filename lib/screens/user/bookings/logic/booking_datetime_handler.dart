import 'package:flutter/material.dart';
import '../../../../utils/event_bus.dart';
import 'booking_form_data.dart';

/// Gestionnaire pour la sélection de date et heure
class BookingDateTimeHandler {
  // Getters pour exposer les valeurs depuis BookingFormData
  DateTime? get selectedDate => BookingFormData.instance.selectedDate;
  TimeOfDay? get selectedTime => BookingFormData.instance.selectedTime;

  /// Sélectionner une date
  Future<void> selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: const Locale('fr', 'FR'),
      );

      if (picked != null) {
        BookingFormData.instance.updateSelectedDate(picked);
        EventBus.instance.emit(BookingDateSelected(picked));
      }
    } catch (e) {
      EventBus.instance.emit(
        BookingDateTimeError('Erreur lors de la sélection de date: $e'),
      );
    }
  }

  /// Sélectionner une heure
  Future<void> selectTime(BuildContext context) async {
    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (picked != null) {
        BookingFormData.instance.updateSelectedTime(picked);
        EventBus.instance.emit(BookingTimeSelected(picked));
      }
    } catch (e) {
      EventBus.instance.emit(
        BookingDateTimeError('Erreur lors de la sélection d\'heure: $e'),
      );
    }
  }

  /// Valider que la date/heure est dans le futur
  bool isDateTimeValid(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return false;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return selectedDateTime.isAfter(DateTime.now());
  }
}

/// Event classes
class BookingDateSelected {
  final DateTime date;
  BookingDateSelected(this.date);
}

class BookingTimeSelected {
  final TimeOfDay time;
  BookingTimeSelected(this.time);
}

class BookingDateTimeError {
  final String message;
  BookingDateTimeError(this.message);
}
