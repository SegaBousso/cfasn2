import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onSelect;
  final Function(BookingStatus)? onStatusChanged;

  const BookingCard({
    super.key,
    required this.booking,
    this.isSelected = false,
    this.onTap,
    this.onSelect,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec sélection et actions
              Row(
                children: [
                  if (onSelect != null)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onSelect?.call(),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.service.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Réservation #${booking.id.substring(0, 8)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(booking.status),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, context),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('Voir détails'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit_status',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Changer statut'),
                          dense: true,
                        ),
                      ),
                      if (booking.status == BookingStatus.pending)
                        const PopupMenuItem(
                          value: 'assign_provider',
                          child: ListTile(
                            leading: Icon(Icons.person_add),
                            title: Text('Assigner prestataire'),
                            dense: true,
                          ),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Informations principales
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn([
                      _buildInfoRow(Icons.person, 'Client', booking.userName),
                      _buildInfoRow(Icons.email, 'Email', booking.userEmail),
                      if (booking.userPhone != null)
                        _buildInfoRow(
                          Icons.phone,
                          'Téléphone',
                          booking.userPhone!,
                        ),
                    ]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoColumn([
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Date service',
                        DateFormat(
                          'dd/MM/yyyy à HH:mm',
                        ).format(booking.serviceDate),
                      ),
                      if (booking.providerName != null)
                        _buildInfoRow(
                          Icons.business,
                          'Prestataire',
                          booking.providerName!,
                        ),
                      _buildInfoRow(
                        Icons.access_time,
                        'Créé le',
                        DateFormat('dd/MM/yyyy').format(booking.createdAt),
                      ),
                    ]),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Paiement et montant
              Row(
                children: [
                  _buildPaymentChip(booking.paymentStatus),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              // Description du service si disponible
              if (booking.serviceDescription.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description du service:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.serviceDescription,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case BookingStatus.confirmed:
        color = Colors.blue;
        icon = Icons.check_circle_outline;
        break;
      case BookingStatus.inProgress:
        color = Colors.purple;
        icon = Icons.play_circle_outline;
        break;
      case BookingStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case BookingStatus.refunded:
        color = Colors.grey;
        icon = Icons.undo;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(PaymentStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case PaymentStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case PaymentStatus.paid:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case PaymentStatus.failed:
        color = Colors.red;
        icon = Icons.error;
        break;
      case PaymentStatus.refunded:
        color = Colors.grey;
        icon = Icons.undo;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'Paiement ${status.label.toLowerCase()}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'view':
        // Navigation vers détails
        Navigator.pushNamed(
          context,
          '/admin/bookings/details',
          arguments: booking.id,
        );
        break;
      case 'edit_status':
        _showStatusDialog(context);
        break;
      case 'assign_provider':
        // TODO: Implémenter l'assignation de prestataire
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignation de prestataire - à implémenter'),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le statut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BookingStatus.values.map((status) {
            return ListTile(
              leading: Icon(
                booking.status == status
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: booking.status == status ? Colors.red[700] : null,
              ),
              title: Text(status.label),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged?.call(status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la réservation'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette réservation ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la suppression
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Suppression - à implémenter')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
