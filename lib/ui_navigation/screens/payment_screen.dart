import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coworkhub/payment_feedback_logic/services/payment_service.dart';
import 'package:coworkhub/payment_feedback_logic/models/invoice.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/ui_navigation/screens/home_screen.dart';
import 'package:coworkhub/ui_navigation/helper/workspace_helpers.dart';
import 'package:coworkhub/ui_navigation/helper/snackbar_helper.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final int userId;
  final String userName;
  final String resourceName;
  final String date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int capacity;
  final double total;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.resourceName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
        Navigator.pop(context); // close bottom sheet
        SnackbarHelper.showSuccess(context, 'Payment successful! Booking confirmed. ');
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
        SnackbarHelper.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showCardBottomSheet(Invoice invoice) {
    final cardController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();
    String detectedCard = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7CCC8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Card Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 20),

                // Card Number
              TextField(
                controller: cardController,
                keyboardType: TextInputType.number,
                maxLength: 19,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                // ✅ Add this
                onChanged: (value) {
                  setSheetState(() {
                    if (value.startsWith('4')) {
                      detectedCard = 'visa';
                    } else if (value.startsWith('5')) {
                      detectedCard = 'mastercard';
                    } else {
                      detectedCard = '';
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: "1234 5678 9012 3456",
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.credit_card_rounded,
                      color: Color(0xFF6D4C41)),
                  // ✅ Add this
                  suffixIcon: detectedCard.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/$detectedCard.png',
                      height: 30,
                    ),
                  )
                      : null,
                  counterText: "",
                  filled: true,
                  fillColor: const Color(0xFFFAF7F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6D4C41)),
                  ),
                ),
              ),

                const SizedBox(height: 16),

                // Cardholder Name
                const Text(
                  "Cardholder Name",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "John Doe",
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: Color(0xFF6D4C41)),
                    filled: true,
                    fillColor: const Color(0xFFFAF7F4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6D4C41)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Expiry and CVV
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Expiry Date",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: expiryController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            decoration: InputDecoration(
                              hintText: "MM/YY",
                              hintStyle:
                              const TextStyle(color: Color(0xFF9CA3AF)),
                              counterText: "",
                              filled: true,
                              fillColor: const Color(0xFFFAF7F4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Color(0xFFD7CCC8)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Color(0xFFD7CCC8)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Color(0xFF6D4C41)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "CVV",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "123",
                              hintStyle:
                              const TextStyle(color: Color(0xFF9CA3AF)),
                              counterText: "",
                              filled: true,
                              fillColor: const Color(0xFFFAF7F4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Color(0xFFD7CCC8)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Color(0xFFD7CCC8)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Color(0xFF6D4C41)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Total
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EDE8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      Text(
                        "\$${invoice.total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pay Now Button
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
                        : const Text(
                      "Pay Now",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
            ); // closes Container
          }, // closes StatefulBuilder
      ), // closes showModalBottomSheet
    );
  }

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

                // ── Booking Info Card ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD7CCC8)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          WorkspaceHelpers.getImage(widget.resourceName),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 80,
                                height: 80,
                                color: const Color(0xFFE8D5D0),
                                child: const Icon(Icons.meeting_room_rounded,
                                    size: 35, color: Color(0xFF8D6E63)),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.resourceName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 12, color: Color(0xFF8D6E63)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  WorkspaceHelpers.getLocation(
                                      widget.resourceName),
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF8D6E63)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 12, color: Color(0xFF8D6E63)),
                              const SizedBox(width: 4),
                              Text(widget.date,
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF8D6E63))),
                            ]),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.access_time_outlined,
                                  size: 12, color: Color(0xFF8D6E63)),
                              const SizedBox(width: 4),
                              Text(
                                widget.startTime != null &&
                                    widget.endTime != null
                                    ? "${widget.startTime!.format(context)} – ${widget.endTime!.format(context)}"
                                    : "N/A",
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF8D6E63)),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.people_outline,
                                  size: 12, color: Color(0xFF8D6E63)),
                              const SizedBox(width: 4),
                              Text("Up to ${widget.capacity} people",
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF8D6E63))),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Select Payment Method ──
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
                        'Credit / Debit Card',
                        [
                          'assets/images/visa.png',
                          'assets/images/mastercard.png',
                        ],
                      ),
                      _divider(),
                      _paymentMethodTile(
                        'PayPal',
                        'PayPal',
                        ['assets/images/paypal.png'],
                      ),
                      _divider(),
                      _paymentMethodTile(
                        'Apple Pay',
                        'Apple Pay',
                        ['assets/images/apple_pay.png'],
                      ),
                      _divider(),
                      _paymentMethodTile(
                        'Google Pay',
                        'Google Pay',
                        ['assets/images/google_pay.png'],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Proceed to Pay Button ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _showCardBottomSheet(invoice),
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

  Widget _paymentMethodTile(
      String value, String label, List<String> imagePaths) {
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
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF3E2723),
                ),
              ),
            ),
            Row(
              children: imagePaths.map((path) {
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Image.asset(
                    path,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, color: Color(0xFFD7CCC8), indent: 16, endIndent: 16);
}