import 'package:flutter/material.dart';
import '../../../../utils/event_bus.dart';
import '../logic/booking_events.dart';

/// Widget modulaire pour les boutons d'action (réserver, debug)
class ActionButtons extends StatefulWidget {
  final VoidCallback onBookPressed;
  final VoidCallback onDebugViewBookings;
  final VoidCallback onDebugCreateProviders;

  const ActionButtons({
    super.key,
    required this.onBookPressed,
    required this.onDebugViewBookings,
    required this.onDebugCreateProviders,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeEventListeners();
  }

  @override
  void dispose() {
    _cleanupEventListeners();
    super.dispose();
  }

  void _initializeEventListeners() {
    EventBus.instance.on<BookingLoadingChangedEvent>().listen((event) {
      if (mounted) {
        setState(() {
          _isLoading = event.isLoading;
        });
      }
    });
  }

  void _cleanupEventListeners() {
    // Les subscriptions se nettoient automatiquement avec le dispose du widget
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBookButton(),
        const SizedBox(height: 16),
        _buildDebugViewButton(),
        const SizedBox(height: 8),
        _buildDebugCreateButton(),
      ],
    );
  }

  /// Construit le bouton principal de réservation
  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : widget.onBookPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Confirmer la réservation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Construit le bouton de debug pour voir les réservations
  Widget _buildDebugViewButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: widget.onDebugViewBookings,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Debug: Voir les réservations dans Firestore',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  /// Construit le bouton de debug pour créer des providers
  Widget _buildDebugCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: widget.onDebugCreateProviders,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Debug: Créer des providers d\'exemple',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
