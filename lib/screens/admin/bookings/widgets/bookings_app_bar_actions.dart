import 'package:flutter/material.dart';
import '../../../../models/models.dart';

/// App bar actions widget for bookings management
class BookingsAppBarActions extends StatelessWidget {
  final bool hasSelection;
  final VoidCallback onRefresh;
  final Function(BookingStatus) onBulkStatusUpdate;

  const BookingsAppBarActions({
    super.key,
    required this.hasSelection,
    required this.onRefresh,
    required this.onBulkStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: 'Actualiser',
        ),
        if (hasSelection)
          PopupMenuButton<BookingStatus>(
            icon: const Icon(Icons.edit),
            tooltip: 'Actions groupées',
            onSelected: onBulkStatusUpdate,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: BookingStatus.confirmed,
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Confirmer sélection'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: BookingStatus.cancelled,
                child: ListTile(
                  leading: Icon(Icons.cancel, color: Colors.red),
                  title: Text('Annuler sélection'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: BookingStatus.completed,
                child: ListTile(
                  leading: Icon(Icons.done_all, color: Colors.blue),
                  title: Text('Marquer terminées'),
                  dense: true,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
