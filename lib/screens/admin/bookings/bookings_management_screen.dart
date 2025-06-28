import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../models/booking_model.dart';
import 'admin_booking_manager.dart';
import 'widgets/booking_card.dart';
import 'widgets/booking_filters.dart';

class BookingsManagementScreen extends StatefulWidget {
  const BookingsManagementScreen({super.key});

  @override
  State<BookingsManagementScreen> createState() =>
      _BookingsManagementScreenState();
}

class _BookingsManagementScreenState extends State<BookingsManagementScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<BookingModel> _bookings = [];
  List<BookingModel> _filteredBookings = [];
  Set<String> _selectedBookingIds = {};

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';

  // Filtres
  BookingStatus? _selectedStatus;
  PaymentStatus? _selectedPaymentStatus;
  DateTimeRange? _selectedDateRange;
  double? _minAmount;
  double? _maxAmount;

  // Pagination
  static const int _pageSize = 20;
  bool _hasMoreData = true;

  // Stats
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _loadStats();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreBookings();
    }
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    try {
      final bookings = await AdminBookingManager.getAllBookings(
        limit: _pageSize,
        statusFilter: _selectedStatus,
        searchQuery: _searchQuery,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      setState(() {
        _bookings = bookings;
        _applyFilters();
        _hasMoreData = bookings.length == _pageSize;
      });
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

  Future<void> _loadMoreBookings() async {
    if (_bookings.isEmpty) return;

    setState(() => _isLoadingMore = true);

    try {
      // TODO: Implémenter la pagination avec DocumentSnapshot
      final moreBookings = await AdminBookingManager.getAllBookings(
        limit: _pageSize,
        statusFilter: _selectedStatus,
        searchQuery: _searchQuery,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      setState(() {
        _bookings.addAll(moreBookings);
        _applyFilters();
        _hasMoreData = moreBookings.length == _pageSize;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await AdminBookingManager.getBookingStats();
      setState(() => _stats = stats);
    } catch (e) {
      print('Erreur lors du chargement des stats: $e');
    }
  }

  void _applyFilters() {
    List<BookingModel> filtered = List.from(_bookings);

    // Filtre par montant
    if (_minAmount != null) {
      filtered = filtered
          .where((booking) => booking.totalAmount >= _minAmount!)
          .toList();
    }
    if (_maxAmount != null) {
      filtered = filtered
          .where((booking) => booking.totalAmount <= _maxAmount!)
          .toList();
    }

    // Filtre par statut de paiement
    if (_selectedPaymentStatus != null) {
      filtered = filtered
          .where((booking) => booking.paymentStatus == _selectedPaymentStatus)
          .toList();
    }

    setState(() {
      _filteredBookings = filtered;
    });
  }

  Future<void> _refreshData() async {
    _selectedBookingIds.clear();
    await _loadBookings();
    await _loadStats();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _debounceSearch();
  }

  Timer? _searchDebounce;
  void _debounceSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _loadBookings();
    });
  }

  Future<void> _updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    final success = await AdminBookingManager.updateBookingStatus(
      bookingId,
      newStatus,
    );

    if (success) {
      await _refreshData();
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
  }

  Future<void> _bulkUpdateStatus(BookingStatus newStatus) async {
    if (_selectedBookingIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Modifier le statut de ${_selectedBookingIds.length} réservation(s) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await AdminBookingManager.bulkUpdateStatus(
        _selectedBookingIds.toList(),
        newStatus,
      );

      if (success) {
        _selectedBookingIds.clear();
        await _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Statuts mis à jour avec succès')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des réservations'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading:
            false, // Empêche l'affichage de l'icône de retour
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          if (_selectedBookingIds.isNotEmpty)
            PopupMenuButton<BookingStatus>(
              icon: const Icon(Icons.edit),
              tooltip: 'Actions groupées',
              onSelected: _bulkUpdateStatus,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: BookingStatus.confirmed,
                  child: Text('Confirmer sélection'),
                ),
                const PopupMenuItem(
                  value: BookingStatus.cancelled,
                  child: Text('Annuler sélection'),
                ),
                const PopupMenuItem(
                  value: BookingStatus.completed,
                  child: Text('Marquer terminées'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques en en-tête
          if (_stats.isNotEmpty) _buildStatsHeader(),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par client, email, service...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Filtres
          BookingFilters(
            selectedStatus: _selectedStatus,
            selectedPaymentStatus: _selectedPaymentStatus,
            dateRange: _selectedDateRange,
            minAmount: _minAmount,
            maxAmount: _maxAmount,
            onStatusChanged: (BookingStatus? status) {
              setState(() => _selectedStatus = status);
              _loadBookings();
            },
            onPaymentStatusChanged: (PaymentStatus? status) {
              setState(() => _selectedPaymentStatus = status);
              _applyFilters();
            },
            onDateRangeChanged: (range) {
              setState(() => _selectedDateRange = range);
              _loadBookings();
            },
            onAmountRangeChanged: (min, max) {
              setState(() {
                _minAmount = min;
                _maxAmount = max;
              });
              _applyFilters();
            },
            onClearFilters: () {
              setState(() {
                _selectedStatus = null;
                _selectedPaymentStatus = null;
                _selectedDateRange = null;
                _minAmount = null;
                _maxAmount = null;
              });
              _loadBookings();
            },
          ),

          // Sélection groupée
          if (_selectedBookingIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Text(
                '${_selectedBookingIds.length} réservation(s) sélectionnée(s)',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Liste des réservations
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          _filteredBookings.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _filteredBookings.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final booking = _filteredBookings[index];
                        final isSelected = _selectedBookingIds.contains(
                          booking.id,
                        );

                        return BookingCard(
                          booking: booking,
                          isSelected: isSelected,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/admin/bookings/details',
                            arguments: booking.id,
                          ),
                          onSelect: () {
                            setState(() {
                              if (isSelected) {
                                _selectedBookingIds.remove(booking.id);
                              } else {
                                _selectedBookingIds.add(booking.id);
                              }
                            });
                          },
                          onStatusChanged: (newStatus) =>
                              _updateBookingStatus(booking.id, newStatus),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[700]!, Colors.red[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatItem(
            'Total',
            _stats['total']?.toString() ?? '0',
            Icons.bookmark,
          ),
          _buildStatItem(
            'Ce mois',
            _stats['thisMonth']?.toString() ?? '0',
            Icons.calendar_today,
          ),
          _buildStatItem(
            'Revenue',
            '${(_stats['totalRevenue'] ?? 0).toStringAsFixed(0)}€',
            Icons.euro,
          ),
          _buildStatItem(
            'Croissance',
            '${(_stats['monthlyGrowth'] ?? 0).toStringAsFixed(1)}%',
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune réservation trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres de recherche',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
