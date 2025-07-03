import 'package:flutter/material.dart';
import '../../../models/models.dart';

// Logic Handlers
import 'logic/booking_form_data.dart';
import 'logic/booking_datetime_handler.dart';
import 'logic/booking_address_handler.dart';
import 'logic/booking_notes_handler.dart';
import 'logic/booking_save_handler.dart';
import 'logic/booking_event_handler.dart';

// Modular Widgets
import 'widgets/service_card.dart';
import 'widgets/pricing_section.dart';
import 'widgets/action_buttons.dart';
import 'widgets/form_sections/datetime_section.dart';
import 'widgets/form_sections/address_section.dart';
import 'widgets/form_sections/notes_section.dart';

class CreateBookingScreen extends StatefulWidget {
  final ServiceModel service;

  const CreateBookingScreen({super.key, required this.service});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Logic Handlers
  late final BookingFormData _formData;
  late final BookingDateTimeHandler _dateTimeHandler;
  late final BookingAddressHandler _addressHandler;
  late final BookingNotesHandler _notesHandler;
  late final BookingSaveHandler _saveHandler;
  late final BookingEventHandler _eventHandler;

  @override
  void initState() {
    super.initState();
    _initializeHandlers();
    _eventHandler.initializeEventListeners();
  }

  @override
  void dispose() {
    _eventHandler.dispose();
    super.dispose();
  }

  /// Initialise tous les handlers de logique
  void _initializeHandlers() {
    _formData = BookingFormData.instance;
    _dateTimeHandler = BookingDateTimeHandler();
    _addressHandler = BookingAddressHandler();
    _notesHandler = BookingNotesHandler();
    _saveHandler = BookingSaveHandler();
    _eventHandler = BookingEventHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Réservation'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ServiceCard(service: widget.service),
              const SizedBox(height: 24),
              DateTimeSection(handler: _dateTimeHandler),
              const SizedBox(height: 24),
              AddressSection(handler: _addressHandler),
              const SizedBox(height: 24),
              NotesSection(handler: _notesHandler),
              const SizedBox(height: 24),
              PricingSection(service: widget.service),
              const SizedBox(height: 32),
              ActionButtons(
                onBookPressed: _handleBookPressed,
                onDebugViewBookings: () =>
                    _eventHandler.debugViewBookings(context),
                onDebugCreateProviders: () =>
                    _eventHandler.debugCreateProviders(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gère l'appui sur le bouton de réservation
  Future<void> _handleBookPressed() async {
    // Synchroniser les données du formulaire
    _syncFormData();

    // Valider le formulaire
    if (!_eventHandler.validateBookingForm(
      formKey: _formKey,
      selectedDate: _dateTimeHandler.selectedDate,
      selectedTime: _dateTimeHandler.selectedTime,
      context: context,
    )) {
      return;
    }

    // Soumettre la réservation
    final booking = await _saveHandler.submitBooking(
      context: context,
      service: widget.service,
      formData: _formData,
    );

    // Si la réservation a été créée avec succès, retourner à l'écran précédent
    if (booking != null && mounted) {
      Navigator.pop(context, booking);
    }
  }

  /// Synchronise les données de tous les handlers dans le FormData
  void _syncFormData() {
    print('🔄 Synchronisation des données du formulaire:');
    print('   - Date sélectionnée: ${_dateTimeHandler.selectedDate}');
    print('   - Heure sélectionnée: ${_dateTimeHandler.selectedTime}');
    print('   - Adresse: ${_addressHandler.selectedAddress}');
    print('   - Notes: ${_notesHandler.notes}');

    _formData.updateDateTime(
      _dateTimeHandler.selectedDate,
      _dateTimeHandler.selectedTime,
    );
    _formData.updateAddress(_addressHandler.selectedAddress);
    _formData.updateNotes(_notesHandler.notes);

    print('✅ FormData synchronisé:');
    print('   - Date dans FormData: ${_formData.selectedDate}');
    print('   - Heure dans FormData: ${_formData.selectedTime}');
    print('   - Adresse dans FormData: ${_formData.selectedAddress}');
  }
}
