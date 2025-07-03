import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../utils/event_bus.dart';

/// Singleton pour gérer les données du formulaire de réservation
class BookingFormData {
  static final BookingFormData _instance = BookingFormData._internal();
  factory BookingFormData() => _instance;
  static BookingFormData get instance => _instance;
  BookingFormData._internal();

  // Données du formulaire
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedAddress = '';
  String _notes = '';
  ServiceModel? _service;
  bool _isLoading = false;

  // Getters
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  String get selectedAddress => _selectedAddress;
  String get notes => _notes;
  ServiceModel? get service => _service;
  bool get isLoading => _isLoading;

  // Computed properties
  bool get isDateTimeValid => _selectedDate != null && _selectedTime != null;
  bool get isAddressValid => _selectedAddress.trim().isNotEmpty;
  bool get isFormValid => isDateTimeValid && isAddressValid;

  DateTime? get serviceDateTime {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  // Update methods
  void updateSelectedDate(DateTime? date) {
    _selectedDate = date;
    _notifyListeners();
  }

  void updateSelectedTime(TimeOfDay? time) {
    _selectedTime = time;
    _notifyListeners();
  }

  void updateAddress(String address) {
    _selectedAddress = address;
    _notifyListeners();
  }

  void updateNotes(String notes) {
    _notes = notes;
    _notifyListeners();
  }

  void updateLoadingState(bool isLoading) {
    _isLoading = isLoading;
    _notifyListeners();
  }

  /// Met à jour à la fois la date et l'heure
  void updateDateTime(DateTime? date, TimeOfDay? time) {
    _selectedDate = date;
    _selectedTime = time;
    _notifyListeners();
  }

  /// Initialize form data with service
  void initializeWithService(ServiceModel service) {
    _service = service;
    _selectedDate = null;
    _selectedTime = null;
    _selectedAddress = '';
    _notes = '';
    _isLoading = false;
    _notifyListeners();
  }

  /// Create BookingModel from current data
  BookingModel createBookingModel({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    String? userAddress,
    String? providerId,
    String? providerName,
  }) {
    if (_service == null || serviceDateTime == null) {
      throw Exception(
        'Service et date/heure requis pour créer une réservation',
      );
    }

    return BookingModel(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      userAddress: userAddress ?? _selectedAddress,
      bookingDate: DateTime.now(),
      serviceDate: serviceDateTime!,
      service: _service!,
      status: BookingStatus.pending,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: 'card',
      serviceDescription: _service!.description,
      additionalDetails: _notes.trim(),
      totalAmount: _service!.price,
      currency: _service!.currency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      providerId: providerId,
      providerName: providerName,
      metadata: {
        'source': 'mobile_app',
        'serviceCategory': _service!.categoryId,
        'bookingMethod': 'instant',
      },
    );
  }

  /// Reset form data
  void reset() {
    _selectedDate = null;
    _selectedTime = null;
    _selectedAddress = '';
    _notes = '';
    _service = null;
    _isLoading = false;
    _notifyListeners();
  }

  /// Notify listeners of changes
  void _notifyListeners() {
    EventBus.instance.emit(BookingFormDataUpdated(this));
  }
}

/// Event classes
class BookingFormDataUpdated {
  final BookingFormData formData;
  BookingFormDataUpdated(this.formData);
}
