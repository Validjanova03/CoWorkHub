import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/payment_feedback_logic/screens/payment_screen.dart';
import 'package:coworkhub/ui_navigation/screens/home_screen.dart';

class BookingScreen extends StatefulWidget {
  final int userId;
  final int resourceId;
  final String resourceName;
  final double rate;
  final int capacity;
  final String spaceType;

  const BookingScreen({
    super.key,
    required this.userId,
    required this.resourceId,
    required this.resourceName,
    required this.rate,
    required this.capacity,
    required this.spaceType,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final DBHelper dbHelper = DBHelper();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _durationHours = 0;
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
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _calculateDuration();
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _calculateDuration();
      });
    }
  }

  void _calculateDuration() {
    if (_startTime != null && _endTime != null) {
      int startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      int endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      _durationHours = (endMinutes - startMinutes) ~/ 60;
      if (_durationHours < 0) _durationHours = 0;
      setState(() {});
    }
  }

  double get _totalPrice => widget.rate * _durationHours;

  Future<void> _confirmBooking() async {
    if (_selectedDate == null) {
      _showError("Please select a date");
      return;
    }
    if (_startTime == null) {
      _showError("Please select start time");
      return;
    }
    if (_endTime == null) {
      _showError("Please select end time");
      return;
    }
    if (_durationHours <= 0) {
      _showError("End time must be after start time");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      if (startDateTime.isBefore(DateTime.now())) {
        _showError("Start time cannot be in the past");
        setState(() => _isLoading = false);
        return;
      }
    final conflicts = await dbHelper.checkConflictingBookings(
      widget.resourceId,
      startDateTime.toString(),
      endDateTime.toString(),
    );

    if (conflicts.isNotEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This workspace is already booked for that time')),
      );

      return;
    }
      int bookingId = await dbHelper.insertBooking({
        'user_id': widget.userId,
        'resource_id': widget.resourceId,
        'start_time': startDateTime.toString(),
        'end_time': endDateTime.toString(),
        'booking_status': 'Pending',
      });

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show dialog with option to proceed to payment
      _showPaymentDialog(bookingId);
    } catch (e) {
      _showError("Error creating booking: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showPaymentDialog(int bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Booking Created!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Would you like to proceed to payment?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(
                    userId: widget.userId,
                    userName: "User",
                  ),
                ),
              );
            },
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    bookingId: bookingId,
                    userId: widget.userId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
            ),
            child: const Text("Proceed to Payment"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _getDayName(int weekday) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text("Booking", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
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
            const Text("Review your booking details and confirm",
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.resourceName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8D6E63)),
                    const SizedBox(width: 4),
                    const Text("Istanbul, Turkey", style: TextStyle(fontSize: 12, color: Color(0xFF8D6E63))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.people_outline, size: 14, color: Color(0xFF8D6E63)),
                    const SizedBox(width: 4),
                    Text("Up to ${widget.capacity} people", style: const TextStyle(fontSize: 12, color: Color(0xFF8D6E63))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.attach_money, size: 14, color: Color(0xFF8D6E63)),
                    const SizedBox(width: 4),
                    Text("\$${widget.rate.toStringAsFixed(0)}/hour", style: const TextStyle(fontSize: 12, color: Color(0xFF8D6E63))),
                  ]),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(6)),
                    child: const Text("Available", style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("1. Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Select Date", style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                    Text(
                      _selectedDate != null
                          ? "${_getDayName(_selectedDate!.weekday)}, ${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}"
                          : "Not selected",
                      style: const TextStyle(fontSize: 14, color: Colors.brown),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text("2. Select Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickStartTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.brown),
                          const SizedBox(width: 8),
                          Text(_startTime == null ? "Start Time" : _startTime!.format(context),
                              style: TextStyle(fontSize: 14, color: _startTime == null ? const Color(0xFF9CA3AF) : const Color(0xFF3E2723))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.brown),
                          const SizedBox(width: 8),
                          Text(_endTime == null ? "End Time" : _endTime!.format(context),
                              style: TextStyle(fontSize: 14, color: _endTime == null ? const Color(0xFF9CA3AF) : const Color(0xFF3E2723))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text("3. Duration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total duration", style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                  Text(_durationHours > 0 ? "$_durationHours Hours" : "Select time",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.brown)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("Booking Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _summaryRow("Room", widget.resourceName),
                  const SizedBox(height: 8),
                  _summaryRow(
                    "Date",
                    _selectedDate != null
                        ? "${_getDayName(_selectedDate!.weekday)}, ${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}"
                        : "Not selected",
                  ),
                  const SizedBox(height: 8),
                  _summaryRow(
                    "Time",
                    _startTime != null && _endTime != null
                        ? "${_startTime!.format(context)} - ${_endTime!.format(context)} ($_durationHours Hours)"
                        : "Not selected",
                  ),
                  const SizedBox(height: 8),
                  _summaryRow("Base Price", "\$${widget.rate.toStringAsFixed(0)} x $_durationHours hour${_durationHours != 1 ? 's' : ''}"),
                  const Divider(height: 24),
                  _summaryRow("Total Amount", "\$${_totalPrice.toStringAsFixed(2)}", isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text("Inclusive of all taxes", style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm Booking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            const Text("You can cancel for free up to 2 hours before",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
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
        Text(label, style: TextStyle(fontSize: 13, color: isBold ? const Color(0xFF3E2723) : const Color(0xFF6B7280))),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.brown : const Color(0xFF3E2723))),
      ],
    );
  }
}