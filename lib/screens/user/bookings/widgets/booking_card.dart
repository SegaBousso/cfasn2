import 'package:flutter/material.dart';
import '../../../../models/models.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onActionPressed;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with service name and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.service.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (booking.providerName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Prestataire: ${booking.providerName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),

              const SizedBox(height: 12),

              // Date and time
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(booking.serviceDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              // Address
              if (booking.userAddress != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.userAddress!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Price
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.euro, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Action button for applicable statuses
              if (_shouldShowActionButton()) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onActionPressed,
                      icon: Icon(_getActionIcon()),
                      label: Text(_getActionLabel()),
                      style: TextButton.styleFrom(
                        foregroundColor: _getActionColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (booking.status) {
      case BookingStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        label = 'En attente';
        break;
      case BookingStatus.confirmed:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        label = 'Confirmé';
        break;
      case BookingStatus.inProgress:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        label = 'En cours';
        break;
      case BookingStatus.completed:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Terminé';
        break;
      case BookingStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        label = 'Annulé';
        break;
      case BookingStatus.refunded:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        label = 'Remboursé';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _shouldShowActionButton() {
    return booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.completed;
  }

  IconData _getActionIcon() {
    switch (booking.status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
        return Icons.cancel_outlined;
      case BookingStatus.completed:
        return Icons.rate_review_outlined;
      default:
        return Icons.info_outlined;
    }
  }

  String _getActionLabel() {
    switch (booking.status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
        return 'Annuler';
      case BookingStatus.completed:
        return 'Évaluer';
      default:
        return 'Détails';
    }
  }

  Color _getActionColor() {
    switch (booking.status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
        return Colors.red[700]!;
      case BookingStatus.completed:
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
