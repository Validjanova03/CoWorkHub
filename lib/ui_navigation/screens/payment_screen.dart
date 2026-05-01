import 'package:flutter/material.dart';
import 'package:coworkhub/payment_feedback_logic/services/payment_service.dart';
import 'package:coworkhub/payment_feedback_logic/models/invoice.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/ui_navigation/screens/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final int userId;
  final String userName;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.userId,
    required this.userName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ── Friend 3's logic ──
  final PaymentService paymentService = PaymentService();
  final DBHelper db = DBHelper();
  late Future<Invoice?> _invoiceFuture;
  String _selectedMethod = 'Credit Card';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _invoiceFuture = _getOrCreateInvoice();
  }

  Future<Invoice?> _getOrCreateInvoice() async {
    final existing = await db.getInvoiceByBookingId(widget.bookingId);
    if (existing != null) return Invoice.fromMap(existing);
    return await paymentService.generateInvoiceForBooking(
      widget.bookingId,
      widget.userId,
    );
  }

  Future<void> _pay(Invoice invoice) async {
    setState(() => _isProcessing = true);
    try {
      final success = await paymentService.processPayment(
        invoice.invoiceId!,
        _selectedMethod,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful! Booking confirmed. 🎉')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userId: widget.userId,
              userName: widget.userName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── Your UI ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      appBar: AppBar(
        title: const Text("Payment",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5D4037),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Invoice?>(
        future: _invoiceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6D4C41)));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("Could not create invoice.",
                  style: TextStyle(color: Color(0xFF8D6E63))),
            );
          }

          final invoice = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Price Summary Card
                const Text(
                  "Price Summary",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723)),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD7CCC8)),
                  ),
                  child: Column(
                    children: [
                      _priceRow("Base Price", "\$${invoice.total.toStringAsFixed(2)}"),
                      const Divider(height: 24, color: Color(0xFFD7CCC8)),
                      _priceRow(
                        "Total Amount",
                        "\$${invoice.total.toStringAsFixed(2)}",
                        isBold: true,
                        isLarge: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Method
                const Text(
                  "Select Payment Method",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723)),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD7CCC8)),
                  ),
                  child: Column(
                    children: [
                      _paymentMethodTile(
                        'Credit Card',
                        Icons.credit_card_rounded,
                        'Credit / Debit Card',
                      ),
                      _divider(),
                      _paymentMethodTile(
                        'PayPal',
                        Icons.paypal_rounded,
                        'PayPal',
                      ),
                      _divider(),
                      _paymentMethodTile(
                        'Apple Pay',
                        Icons.apple_rounded,
                        'Apple Pay',
                      ),
                      _divider(),
                      _paymentMethodTile(
                        'Google Pay',
                        Icons.g_mobiledata_rounded,
                        'Google Pay',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _pay(invoice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D4037),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Proceed to Pay",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "\$${invoice.total.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _paymentMethodTile(String value, IconData icon, String label) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              onChanged: (val) => setState(() => _selectedMethod = val!),
              activeColor: const Color(0xFF6D4C41),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: const Color(0xFF6D4C41), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF3E2723),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, color: Color(0xFFD7CCC8), indent: 16, endIndent: 16);

  Widget _priceRow(String label, String value,
      {bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? const Color(0xFF3E2723) : const Color(0xFF8D6E63),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 20 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? const Color(0xFF5D4037) : const Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }
}