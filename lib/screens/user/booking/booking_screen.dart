import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../services/booking_service.dart';
import '../../../services/notification_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/overflow_safe_widgets.dart';

class BookingScreen extends StatefulWidget {
  final ServiceModel service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final BookingService _bookingService = BookingService();
  final NotificationService _notificationService = NotificationService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver le service'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: OverflowSafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
              ? const EdgeInsets.all(16)
              : const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildServiceSummary(),
                const SizedBox(height: 24),
                _buildDateTimeSelection(),
                const SizedBox(height: 24),
                _buildAddressSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 24),
                _buildPriceSummary(),
                const SizedBox(height: 32),
                _buildBookingButton(),
                const SizedBox(height: 16),
                // Bouton de debug temporaire
                if (kDebugMode) _buildDebugButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé du service',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.service.imageUrl ?? widget.service.displayImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.service.categoryName,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(widget.service.rating.toStringAsFixed(1)),
                          const SizedBox(width: 8),
                          Text(
                            widget.service.formattedPrice,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date et heure',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Sélectionner une date',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Sélectionner l\'heure',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adresse du service',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse complète *',
                hintText: '123 Rue Example, 75001 Paris',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'adresse est requise';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes supplémentaires',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Informations supplémentaires pour le prestataire (optionnel)',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Précisions sur le service, accès, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé de la réservation',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Prix du service'),
                Text(widget.service.formattedPrice),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.service.formattedPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _confirmBooking,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Confirmer la réservation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildDebugButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final user = authProvider.user;

          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Utilisateur non connecté')),
            );
            return;
          }

          print('🔍 Vérification des réservations existantes...');
          final bookings = await _bookingService.getUserBookings(user.uid);

          print('📊 Nombre de réservations trouvées: ${bookings.length}');
          for (final booking in bookings) {
            print('   Réservation ID: ${booking.id}');
            print('   Service: ${booking.service.name}');
            print('   Date: ${booking.serviceDate}');
            print('   Statut: ${booking.status}');
            print('   ---');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${bookings.length} réservations trouvées'),
              backgroundColor: Colors.blue,
            ),
          );
        } catch (e) {
          print('Erreur lors de la vérification: $e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      child: const Text('Debug: Vérifier réservations'),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date et une heure'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Debug : Vérifier l'authentification
      print('🔐 Utilisateur connecté: ${user.uid}');
      print('📧 Email: ${user.email}');

      final bookingDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Debug : Vérifier les données de réservation
      print('📅 Date de réservation: $bookingDateTime');
      print('🏠 Adresse: ${_addressController.text.trim()}');

      final booking = BookingModel.create(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        user: user,
        service: widget.service,
        serviceDate: bookingDateTime,
        paymentMethod: 'cash',
        serviceDescription: widget.service.description,
        additionalDetails:
            '${_addressController.text.trim()}\n\nNotes: ${_notesController.text.trim()}',
      );

      print('💾 Tentative de création de réservation...');
      print('📋 Données de la réservation:');
      print('   ID: ${booking.id}');
      print('   Utilisateur: ${booking.userId}');
      print('   Service: ${booking.service.name}');
      print('   Service ID: ${booking.service.id}');
      print('   Service Provider ID: ${booking.service.providerId}');
      print('   Date: $bookingDateTime');
      print('   Prix: ${booking.totalAmount}');
      print('   Provider ID du booking: ${booking.providerId}');

      final bookingId = await _bookingService.createBooking(booking);

      if (bookingId != null && bookingId.isNotEmpty) {
        print('✅ Réservation créée avec succès ! ID: $bookingId');

        // Envoyer une notification
        try {
          await _notificationService.notifyBookingConfirmed(
            user.uid,
            widget.service.name,
            bookingId,
          );
          print('📱 Notification envoyée');
        } catch (notificationError) {
          print('⚠️ Erreur notification: $notificationError');
          // Ne pas faire échouer la réservation si la notification échoue
        }

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Réservation créée avec succès ! ID: $bookingId'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ La création de réservation a échoué (ID null ou vide)');
        throw Exception('Erreur lors de la création de la réservation');
      }
    } catch (e, stackTrace) {
      print('❌ Erreur lors de la création de réservation: $e');
      print('📚 Stack trace: $stackTrace');

      String errorMessage;
      if (e.toString().contains('permission')) {
        errorMessage = 'Erreur de permissions. Vérifiez votre connexion.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      } else if (e.toString().contains('Données de réservation invalides')) {
        errorMessage = 'Les données de réservation sont incorrectes.';
      } else if (e.toString().contains('Service non disponible')) {
        errorMessage = 'Ce service n\'est plus disponible à cette date.';
      } else {
        errorMessage = 'Erreur: ${e.toString()}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
