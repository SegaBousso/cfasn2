import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/booking_model.dart';
import 'admin_booking_manager.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  BookingModel? _booking;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    setState(() => _isLoading = true);

    try {
      final booking = await AdminBookingManager.getBookingById(
        widget.bookingId,
      );
      setState(() => _booking = booking);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateBookingStatus(BookingStatus newStatus) async {
    setState(() => _isUpdating = true);

    try {
      String? reason;
      if (newStatus == BookingStatus.cancelled) {
        reason = await _showCancellationDialog();
        if (reason == null) {
          setState(() => _isUpdating = false);
          return;
        }
      }

      final success = await AdminBookingManager.updateBookingStatus(
        widget.bookingId,
        newStatus,
        reason: reason,
      );

      if (success) {
        await _loadBookingDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Statut mis à jour avec succès')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la mise à jour')),
          );
        }
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _updatePaymentStatus(PaymentStatus newStatus) async {
    setState(() => _isUpdating = true);

    try {
      final success = await AdminBookingManager.updatePaymentStatus(
        widget.bookingId,
        newStatus,
      );

      if (success) {
        await _loadBookingDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Statut de paiement mis à jour')),
          );
        }
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<String?> _showCancellationDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raison de l\'annulation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Expliquez la raison de l\'annulation...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la réservation'),
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la réservation'),
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Réservation non trouvée')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Réservation #${_booking!.id.substring(0, 8)}'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          if (_isUpdating)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit_status',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Changer statut'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit_payment',
                  child: ListTile(
                    leading: Icon(Icons.payment),
                    title: Text('Modifier paiement'),
                    dense: true,
                  ),
                ),
                if (_booking!.status == BookingStatus.pending)
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statuts
            _buildStatusHeader(),

            const SizedBox(height: 24),

            // Informations client
            _buildSection('Informations client', Icons.person, [
              _buildInfoRow('Nom', _booking!.userName),
              _buildInfoRow('Email', _booking!.userEmail),
              if (_booking!.userPhone != null)
                _buildInfoRow('Téléphone', _booking!.userPhone!),
              if (_booking!.userAddress != null)
                _buildInfoRow('Adresse', _booking!.userAddress!),
            ]),

            const SizedBox(height: 24),

            // Informations service
            _buildSection('Service demandé', Icons.build, [
              _buildInfoRow('Service', _booking!.service.name),
              _buildInfoRow('Catégorie', _booking!.service.categoryId),
              _buildInfoRow(
                'Date du service',
                DateFormat('dd/MM/yyyy à HH:mm').format(_booking!.serviceDate),
              ),
              if (_booking!.providerName != null)
                _buildInfoRow('Prestataire', _booking!.providerName!),
            ]),

            const SizedBox(height: 24),

            // Détails financiers
            _buildSection('Détails financiers', Icons.euro, [
              _buildInfoRow(
                'Montant total',
                '${_booking!.totalAmount.toStringAsFixed(2)} ${_booking!.currency}',
              ),
              _buildInfoRow('Mode de paiement', _booking!.paymentMethod),
            ]),

            const SizedBox(height: 24),

            // Description et détails
            if (_booking!.serviceDescription.isNotEmpty)
              _buildSection('Description du service', Icons.description, [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(_booking!.serviceDescription),
                ),
              ]),

            if (_booking!.additionalDetails.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection('Détails supplémentaires', Icons.info, [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(_booking!.additionalDetails),
                ),
              ]),
            ],

            const SizedBox(height: 24),

            // Métadonnées
            _buildSection('Informations système', Icons.info_outline, [
              _buildInfoRow(
                'Créé le',
                DateFormat('dd/MM/yyyy à HH:mm').format(_booking!.createdAt),
              ),
              _buildInfoRow(
                'Dernière modification',
                DateFormat('dd/MM/yyyy à HH:mm').format(_booking!.updatedAt),
              ),
              _buildInfoRow('ID de réservation', _booking!.id),
              if (_booking!.cancellationReason != null) ...[
                const Divider(),
                _buildInfoRow(
                  'Raison de l\'annulation',
                  _booking!.cancellationReason!,
                ),
                if (_booking!.cancelledAt != null)
                  _buildInfoRow(
                    'Annulé le',
                    DateFormat(
                      'dd/MM/yyyy à HH:mm',
                    ).format(_booking!.cancelledAt!),
                  ),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[700]!, Colors.red[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _booking!.service.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusChip(
                'Réservation',
                _booking!.status.label,
                _getStatusColor(_booking!.status),
              ),
              const SizedBox(width: 12),
              _buildStatusChip(
                'Paiement',
                _booking!.paymentStatus.label,
                _getPaymentColor(_booking!.paymentStatus),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.refunded:
        return Colors.grey;
    }
  }

  Color _getPaymentColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.grey;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit_status':
        _showStatusDialog();
        break;
      case 'edit_payment':
        _showPaymentStatusDialog();
        break;
      case 'assign_provider':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignation de prestataire - à implémenter'),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le statut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BookingStatus.values.map((status) {
            final isSelected = _booking!.status == status;
            return ListTile(
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? Colors.red[700] : null,
              ),
              title: Text(status.label),
              onTap: () {
                Navigator.pop(context);
                if (status != _booking!.status) {
                  _updateBookingStatus(status);
                }
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

  void _showPaymentStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le statut de paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PaymentStatus.values.map((status) {
            final isSelected = _booking!.paymentStatus == status;
            return ListTile(
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? Colors.red[700] : null,
              ),
              title: Text(status.label),
              onTap: () {
                Navigator.pop(context);
                if (status != _booking!.paymentStatus) {
                  _updatePaymentStatus(status);
                }
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la réservation'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette réservation ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await AdminBookingManager.deleteBooking(
                widget.bookingId,
              );
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Réservation supprimée')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
