import 'package:flutter/material.dart';
import '../../../../models/booking_model.dart';

class BookingFilters extends StatefulWidget {
  final BookingStatus? selectedStatus;
  final PaymentStatus? selectedPaymentStatus;
  final DateTimeRange? dateRange;
  final double? minAmount;
  final double? maxAmount;
  final Function(BookingStatus?) onStatusChanged;
  final Function(PaymentStatus?) onPaymentStatusChanged;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(double?, double?) onAmountRangeChanged;
  final VoidCallback onClearFilters;

  const BookingFilters({
    super.key,
    this.selectedStatus,
    this.selectedPaymentStatus,
    this.dateRange,
    this.minAmount,
    this.maxAmount,
    required this.onStatusChanged,
    required this.onPaymentStatusChanged,
    required this.onDateRangeChanged,
    required this.onAmountRangeChanged,
    required this.onClearFilters,
  });

  @override
  State<BookingFilters> createState() => _BookingFiltersState();
}

class _BookingFiltersState extends State<BookingFilters> {
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _minAmountController.text = widget.minAmount?.toString() ?? '';
    _maxAmountController.text = widget.maxAmount?.toString() ?? '';
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Colors.grey[600]),
                const SizedBox(width: 8),
                const Text(
                  'Filtres',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    widget.onClearFilters();
                    _minAmountController.clear();
                    _maxAmountController.clear();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Effacer'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filtres en ligne
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Statut de réservation
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<BookingStatus>(
                    value: widget.selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bookmark),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tous les statuts'),
                      ),
                      ...BookingStatus.values.map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(status.label),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: widget.onStatusChanged,
                  ),
                ),

                // Statut de paiement
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<PaymentStatus>(
                    value: widget.selectedPaymentStatus,
                    decoration: const InputDecoration(
                      labelText: 'Paiement',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tous les paiements'),
                      ),
                      ...PaymentStatus.values.map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(
                                _getPaymentIcon(status),
                                size: 16,
                                color: _getPaymentColor(status),
                              ),
                              const SizedBox(width: 8),
                              Text(status.label),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: widget.onPaymentStatusChanged,
                  ),
                ),

                // Sélecteur de dates
                SizedBox(
                  width: 250,
                  child: InkWell(
                    onTap: _selectDateRange,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Période',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      child: Text(
                        widget.dateRange != null
                            ? '${_formatDate(widget.dateRange!.start)} - ${_formatDate(widget.dateRange!.end)}'
                            : 'Sélectionner une période',
                        style: TextStyle(
                          color: widget.dateRange != null
                              ? null
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),

                // Montant minimum
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    controller: _minAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Montant min.',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.euro),
                      suffixText: '€',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final minAmount = double.tryParse(value);
                      final maxAmount = double.tryParse(
                        _maxAmountController.text,
                      );
                      widget.onAmountRangeChanged(minAmount, maxAmount);
                    },
                  ),
                ),

                // Montant maximum
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    controller: _maxAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Montant max.',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.euro),
                      suffixText: '€',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final minAmount = double.tryParse(
                        _minAmountController.text,
                      );
                      final maxAmount = double.tryParse(value);
                      widget.onAmountRangeChanged(minAmount, maxAmount);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: widget.dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.red[700]),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateRangeChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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

  IconData _getPaymentIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.hourglass_empty;
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.refunded:
        return Icons.undo;
    }
  }
}
