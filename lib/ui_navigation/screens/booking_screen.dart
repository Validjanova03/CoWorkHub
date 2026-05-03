import 'package:flutter/material.dart';
import 'package:coworkhub/booking_membership_logic/services/booking_service.dart';
import 'package:coworkhub/ui_navigation/screens/payment_screen.dart';
import 'package:coworkhub/payment_feedback_logic/services/payment_service.dart';
import 'package:coworkhub/ui_navigation/screens/home_screen.dart';
import 'package:coworkhub/ui_navigation/helper/workspace_helpers.dart';
import 'package:coworkhub/ui_navigation/helper/snackbar_helper.dart';
class BookingScreen extends StatefulWidget {
  final int userId;
  final int resourceId;
  final String resourceName;
  final double rate;
  final int capacity;
  final String spaceType;
  final String userName;

  const BookingScreen({
    super.key,
    required this.userId,
    required this.resourceId,
    required this.resourceName,
    required this.rate,
    required this.capacity,
    required this.spaceType,
    required this.userName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService bookingService = BookingService();
  final PaymentService paymentService = PaymentService();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double _durationHours = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
      _calculateDuration();
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _endTime = picked);
      _calculateDuration();
    }
  }

  void _calculateDuration() {
    if (_startTime != null && _endTime != null) {
      int startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      int endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      int diffMinutes = endMinutes - startMinutes;
      if (diffMinutes < 0) diffMinutes += 24 * 60;
      if (diffMinutes < 60) {
         _durationHours = 0;
      } else {
        _durationHours = diffMinutes / 60; //  decimal
      }
      setState(() {});
    }
  }

  double get _totalPrice => widget.rate * _durationHours;

  String _formatDate() {
    if (_selectedDate == null) return "Not selected";
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${days[_selectedDate!.weekday - 1]}, ${_selectedDate!.day} "
        "${months[_selectedDate!.month - 1]} ${_selectedDate!.year}";
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null) { _showError("Please select a date"); return; }
    if (_startTime == null) { _showError("Please select start time"); return; }
    if (_endTime == null) { _showError("Please select end time"); return; }
    if (_durationHours <= 0) { _showError("Please select valid time range (minimum 1 hour)"); return; }

    setState(() => _isLoading = true);

    try {
      final startDateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _startTime!.hour, _startTime!.minute,
      );
      final endDateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _endTime!.hour, _endTime!.minute,
      );
      final endDateTimeAdjusted = endDateTime.isBefore(startDateTime)
          ? endDateTime.add(const Duration(days: 1))
          : endDateTime;

      if (startDateTime.isBefore(DateTime.now())) {
        _showError("Start time cannot be in the past");
        setState(() => _isLoading = false);
        return;
      }

      var result = await bookingService.createBooking(
        userId: widget.userId,
        resourceId: widget.resourceId,
        startDateTime: startDateTime,
        endDateTime: endDateTimeAdjusted,
      );

      if (result is String) {
        if (!mounted) return;
        _showError(result);
        setState(() => _isLoading = false);
        return;
      }

      final bookingId = result as int;
      await paymentService.generateInvoiceForBooking(
          bookingId, widget.userId);

      if (!mounted) return;
      setState(() => _isLoading = false);

      _showPaymentDialog(bookingId);


    } catch (e) {
      _showError("Error creating booking: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    SnackbarHelper.showError(context, message);
  }
  void _showPaymentDialog(int bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Booking Created!",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Would you like to proceed to payment?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => HomeScreen(
                  userId: widget.userId,
                  userName: widget.userName,
                ),
              ));
            },
            child: const Text("Later",
                style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => PaymentScreen(
                  bookingId: bookingId,
                  userId: widget.userId,
                  userName: widget.userName,
                  resourceName: widget.resourceName,
                  date: _formatDate(),
                  startTime: _startTime,
                  endTime: _endTime,
                  capacity: widget.capacity,
                  total: _totalPrice,
                ),
              ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41)),
            child: const Text("Proceed to Payment",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text("Booking", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5D4037),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Review your booking details and confirm",
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),

            // Workspace Info Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD7CCC8)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Image.asset(
                      WorkspaceHelpers.getImage(widget.resourceName),
                      width: 120,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 140,
                        color: const Color(0xFFE8D5D0),
                        child: const Icon(Icons.meeting_room,
                            size: 50, color: Color(0xFF8D6E63)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.resourceName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723))),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Color(0xFF8D6E63)),
                            const SizedBox(width: 4),
                            Text(WorkspaceHelpers.getLocation(widget.resourceName),
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF8D6E63))),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.people_outline,
                                size: 14, color: Color(0xFF8D6E63)),
                            const SizedBox(width: 4),
                            Text("Up to ${widget.capacity} people",
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF8D6E63))),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.attach_money,
                                size: 14, color: Color(0xFF8D6E63)),
                            const SizedBox(width: 4),
                            Text("\$${widget.rate.toStringAsFixed(0)}/hour",
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF8D6E63))),
                          ]),
                          const SizedBox(height: 6),
                          Text("Available",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1. Select Date
            const Text("1. Select Date",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723))),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD7CCC8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Select Date",
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF6B7280))),
                    Row(
                      children: [
                        Text(_formatDate(),
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF6D4C41))),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today,
                            size: 18, color: Color(0xFF6D4C41)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Select Time
            const Text("2. Select Time",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickStartTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD7CCC8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Color(0xFF6D4C41)),
                          const SizedBox(width: 8),
                          Text(
                            _startTime == null
                                ? "Start Time"
                                : _startTime!.format(context),
                            style: TextStyle(
                                fontSize: 14,
                                color: _startTime == null
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF3E2723)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward,
                    size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD7CCC8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Color(0xFF6D4C41)),
                          const SizedBox(width: 8),
                          Text(
                            _endTime == null
                                ? "End Time"
                                : _endTime!.format(context),
                            style: TextStyle(
                                fontSize: 14,
                                color: _endTime == null
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF3E2723)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Duration
            const Text("3. Duration",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD7CCC8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total duration",
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF6B7280))),
                  Text(
                    _durationHours > 0
                        ? "${_durationHours.toStringAsFixed(1)} hours"
                        : "Select time",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D4C41)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Booking Summary
            const Text("Booking Summary",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD7CCC8)),
              ),
              child: Column(
                children: [
                  _summaryRow("Room", widget.resourceName),
                  const SizedBox(height: 8),
                  _summaryRow("Date", _formatDate()),
                  const SizedBox(height: 8),
                  _summaryRow(
                    "Time",
                    _startTime != null && _endTime != null
                        ? "${_startTime!.format(context)} - ${_endTime!.format(context)}"
                        : "Not selected",
                  ),
                  const SizedBox(height: 8),
                  _summaryRow(
                    "Duration",
                    _durationHours > 0
                        ? "${_durationHours.toStringAsFixed(1)} hours"
                        : "Not selected",
                  ),
                  const SizedBox(height: 8),
                  _summaryRow(
                    "Base Price",
                    "\$${widget.rate.toStringAsFixed(0)} x ${_durationHours.toStringAsFixed(1)} hours", // ✅
                  ),
                  const Divider(height: 24),
                  _summaryRow(
                    "Total Amount",
                    "\$${_totalPrice.toStringAsFixed(2)}",
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text("Inclusive of all taxes",
                style: TextStyle(
                    fontSize: 11, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm Booking",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold
                    ? const Color(0xFF6D4C41)
                    : const Color(0xFF3E2723))),
      ],
    );
  }
}