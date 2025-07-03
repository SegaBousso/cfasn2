import 'package:flutter/material.dart';

class EmptyBookingsState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const EmptyBookingsState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.event_busy,
    this.onRetry,
    this.retryButtonText,
  });

  const EmptyBookingsState.noBookings({
    super.key,
    this.title = 'Aucune réservation',
    this.message = 'Vous n\'avez aucune réservation pour le moment.',
    this.icon = Icons.event_busy,
    this.onRetry,
    this.retryButtonText,
  });

  const EmptyBookingsState.error({
    super.key,
    this.title = 'Erreur de chargement',
    this.message = 'Impossible de charger vos réservations.',
    this.icon = Icons.error_outline,
    required this.onRetry,
    this.retryButtonText = 'Réessayer',
  });

  const EmptyBookingsState.noFilterResults({
    super.key,
    this.title = 'Aucun résultat',
    this.message =
        'Aucune réservation ne correspond aux critères sélectionnés.',
    this.icon = Icons.filter_list_off,
    this.onRetry,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null && retryButtonText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
