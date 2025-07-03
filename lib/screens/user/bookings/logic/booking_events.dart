import 'package:flutter/material.dart';

/// Événements pour la gestion des réservations

/// Événement émis quand l'adresse est mise à jour
class AddressUpdatedEvent {
  final String address;
  final bool isValid;

  AddressUpdatedEvent({required this.address, required this.isValid});
}

/// Événement émis quand l'adresse est réinitialisée
class AddressResetEvent {}

/// Événement émis quand les notes sont mises à jour
class NotesUpdatedEvent {
  final String notes;
  final bool hasNotes;

  NotesUpdatedEvent({required this.notes, required this.hasNotes});
}

/// Événement émis quand les notes sont réinitialisées
class NotesResetEvent {}

/// Événement émis quand la date/heure est mise à jour
class DateTimeUpdatedEvent {
  final DateTime? date;
  final TimeOfDay? time;

  DateTimeUpdatedEvent({this.date, this.time});
}

/// Événement émis quand la date/heure est réinitialisée
class DateTimeResetEvent {}

/// Événement émis quand une date est sélectionnée
class BookingDateSelected {
  final DateTime date;

  BookingDateSelected(this.date);
}

/// Événement émis quand une heure est sélectionnée
class BookingTimeSelected {
  final TimeOfDay time;

  BookingTimeSelected(this.time);
}

/// Événement émis lors d'erreurs de date/heure
class BookingDateTimeError {
  final String message;

  BookingDateTimeError(this.message);
}

/// Événement émis quand l'état de chargement de réservation change
class BookingLoadingChangedEvent {
  final bool isLoading;

  BookingLoadingChangedEvent({required this.isLoading});
}

/// Événement émis quand un SnackBar est affiché
class SnackBarShownEvent {
  final String type;
  final String message;

  SnackBarShownEvent({required this.type, required this.message});
}

/// Événement émis lors du debug des réservations
class DebugBookingsLoadedEvent {
  final List<dynamic> bookings; // BookingModel list
  final String userId;

  DebugBookingsLoadedEvent({required this.bookings, required this.userId});
}

/// Événement émis lors de la création de providers de debug
class DebugProvidersCreatedEvent {}

/// Événement émis quand les données du formulaire changent
class FormDataChangedEvent {
  final Map<String, dynamic> data;

  FormDataChangedEvent({required this.data});
}

/// Événement émis lors d'erreurs de validation
class ValidationErrorEvent {
  final String field;
  final String message;

  ValidationErrorEvent({required this.field, required this.message});
}
