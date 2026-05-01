import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../services/payment_service.dart';
import '../models/invoice.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final int userId;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.userId,
    required String userName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final DBHelper _db = DBHelper();
  late Future<Invoice?> _invoiceFuture;
  String _selectedMethod = 'Credit Card';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _invoiceFuture = _getOrCreateInvoice();
  }

  Future<Invoice?> _getOrCreateInvoice() async {
    final existing = await _db.getInvoiceByBookingId(widget.bookingId);
    if (existing != null) return Invoice.fromMap(existing);
    return await _paymentService.generateInvoiceForBooking(
      widget.bookingId,
      widget.userId,
    );
  }

  Future<void> _pay(Invoice invoice) async {
    setState(() => _isProcessing = true);
    try {
      final success = await _paymentService.processPayment(
        invoice.invoiceId!,
        _selectedMethod,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful! Booking confirmed.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: FutureBuilder<Invoice?>(
        future: _invoiceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Could not create invoice.'));
          }
          final invoice = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Total Amount'),
                    trailing: Text(
                      '\$${invoice.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Payment Method', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                // Modern SegmentedButton - no deprecation warnings
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Credit Card', label: Text('Credit Card')),
                    ButtonSegment(value: 'PayPal', label: Text('PayPal')),
                  ],
                  selected: {_selectedMethod},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedMethod = newSelection.first;
                    });
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isProcessing ? null : () => _pay(invoice),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : const Text('Pay Now'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}