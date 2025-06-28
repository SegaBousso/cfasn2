import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../services/booking_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/overflow_safe_widgets.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();

  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        final bookings = await _bookingService.getUserBookings(user.uid);
        setState(() {
          _allBookings = bookings;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Utilisateur non connecté';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Confirmées'),
            Tab(text: 'En attente'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
            Tab(text: 'Annulées'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBookings,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList(BookingStatus.confirmed),
                _buildBookingsList(BookingStatus.pending),
                _buildBookingsList(BookingStatus.inProgress),
                _buildBookingsList(BookingStatus.completed),
                _buildBookingsList(BookingStatus.cancelled),
              ],
            ),
    );
  }

  Widget _buildBookingsList(BookingStatus status) {
    final filteredBookings = _allBookings
        .where((booking) => booking.status == status)
        .toList();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getStatusIcon(status), size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(status),
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return OverflowSafeArea(
      child: RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];
            return _buildBookingCard(booking);
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewBookingDetails(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.service.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(booking.serviceDate),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.userAddress ?? 'Adresse non spécifiée',
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${booking.totalAmount.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  if (booking.status == BookingStatus.pending)
                    ElevatedButton(
                      onPressed: () => _cancelBooking(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        text = 'En attente';
        icon = Icons.schedule;
        break;
      case BookingStatus.confirmed:
        color = Colors.blue;
        text = 'Confirmée';
        icon = Icons.check_circle;
        break;
      case BookingStatus.inProgress:
        color = Colors.purple;
        text = 'En cours';
        icon = Icons.play_circle;
        break;
      case BookingStatus.completed:
        color = Colors.green;
        text = 'Terminée';
        icon = Icons.check_circle_outline;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        text = 'Annulée';
        icon = Icons.cancel;
        break;
      case BookingStatus.refunded:
        color = Colors.grey;
        text = 'Remboursée';
        icon = Icons.money_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.inProgress:
        return Icons.play_circle;
      case BookingStatus.completed:
        return Icons.check_circle_outline;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.refunded:
        return Icons.money_off;
    }
  }

  String _getEmptyMessage(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Aucune réservation en attente';
      case BookingStatus.confirmed:
        return 'Aucune réservation confirmée';
      case BookingStatus.inProgress:
        return 'Aucune réservation en cours';
      case BookingStatus.completed:
        return 'Aucune réservation terminée';
      case BookingStatus.cancelled:
        return 'Aucune réservation annulée';
      case BookingStatus.refunded:
        return 'Aucune réservation remboursée';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _viewBookingDetails(BookingModel booking) async {
    // TODO: Naviguer vers l'écran de détail de la réservation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails de la réservation: ${booking.service.name}'),
      ),
    );
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text(
          'Êtes-vous sûr de vouloir annuler "${booking.service.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _bookingService.updateBookingStatus(
          booking.id,
          BookingStatus.cancelled,
        );
        await _loadBookings(); // Recharger les données

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation annulée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'annulation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
