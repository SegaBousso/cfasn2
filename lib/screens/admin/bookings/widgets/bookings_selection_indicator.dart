import 'package:flutter/material.dart';

/// Selection indicator widget for bookings management
class BookingsSelectionIndicator extends StatelessWidget {
  final int selectedCount;

  const BookingsSelectionIndicator({super.key, required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue[50],
      child: Text(
        '$selectedCount réservation(s) sélectionnée(s)',
        style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
      ),
    );
  }
}
