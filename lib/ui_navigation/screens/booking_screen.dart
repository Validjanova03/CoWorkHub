import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/payment_feedback_logic/screens/payment_screen.dart';
import 'package:coworkhub/payment_feedback_logic/services/payment_service.dart';
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
  final PaymentService paymentService = PaymentService();

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
      });
      _calculateDuration(); // Calculate after setting start time
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
      });
      _calculateDuration(); // Calculate after setting end time
    }
  }

  void _calculateDuration() {
    if (_startTime != null && _endTime != null) {
      int startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      int endMinutes = _endTime!.hour * 60 + _endTime!.minute;

      // Calculate difference
      int diffMinutes = endMinutes - startMinutes;

      // If end time is earlier (e.g., 10 PM to 2 AM), add 24 hours
      if (diffMinutes < 0) {
        diffMinutes += 24 * 60;
      }

      // Convert to hours
      _durationHours = diffMinutes ~/ 60;

      // Don't allow zero or negative
      if (_durationHours < 1) {
        _durationHours = 0;
      }

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
      _showError("Please select valid time range (minimum 1 hour)");
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

      // If end time is next day (e.g., 10 PM to 2 AM)
      final endDateTimeAdjusted = endDateTime.isBefore(startDateTime)
          ? endDateTime.add(const Duration(days: 1))
          : endDateTime;

      if (startDateTime.isBefore(DateTime.now())) {
        _showError("Start time cannot be in the past");
        setState(() => _isLoading = false);
        return;
      }

      // Check for conflicting bookings
      final conflicts = await dbHelper.checkConflictingBookings(
        widget.resourceId,
        startDateTime.toString(),
        endDateTimeAdjusted.toString(),
      );

      if (conflicts.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This workspace is already booked for that time')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Create booking
      int bookingId = await dbHelper.insertBooking({
        'user_id': widget.userId,
        'resource_id': widget.resourceId,
        'start_time': startDateTime.toString(),
        'end_time': endDateTimeAdjusted.toString(),
        'booking_status': 'Pending',
      });

      if (!mounted) return;

      // Generate invoice
      final invoice = await paymentService.generateInvoiceForBooking(bookingId, widget.userId);

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show dialog
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
            child: const Text(
              "Later",
              style: TextStyle(color: Colors.black), // ← Text color here
            ),
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
              backgroundColor: const Color(0xFF6D4C41),
            ),
            child: const Text(
              "Proceed to Payment",
              style: TextStyle(color: Colors.white), // ← Text color here
            ),
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

  String _getImage() {
    final name = widget.resourceName;

    if (name.contains('Hot Desk')) {
      if (name == 'Hot Desk 1') return 'assets/images/hot_desk.jpg';
      if (name == 'Hot Desk 2') return 'assets/images/hot_desk2.png';
      if (name == 'Hot Desk 3') return 'assets/images/hot_desk_3.png';
      if (name == 'Hot Desk 4') return 'assets/images/hot_desk_4.png';
      if (name == 'Hot Desk 5') return 'assets/images/hot_desk_5.png';
      return 'assets/images/hot_desk.png';
    }

    if (name.contains('Dedicated Room')) {
      if (name == 'Dedicated Room 1') return 'assets/images/dedicated_desk.jpg';
      if (name == 'Dedicated Room 2') return 'assets/images/dedicated_desk2.png';
      if (name == 'Dedicated Room 3') return 'assets/images/dedicated_room_3.png';
      if (name == 'Dedicated Room 4') return 'assets/images/dedicated_desk_4.png';
      return 'assets/images/dedicated_desk.png';
    }

    if (name.contains('Meeting Room')) {
      if (name == 'Meeting Room 1') return 'assets/images/meeting_room.jpg';
      if (name == 'Meeting Room 2') return 'assets/images/meeting_room2.png';
      if (name == 'Meeting Room 3') return 'assets/images/meeting_room_3.png';
      return 'assets/images/meeting_room.png';
    }

    if (name.contains('Conference Hall')) {
      if (name == 'Conference Hall 1') return 'assets/images/conference_hall.jpg';
      if (name == 'Conference Hall 2') return 'assets/images/conference_hall2.png';
      return 'assets/images/conference_hall.png';
    }

    return 'assets/images/workspace.png';
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
            const Text("Review your booking details and confirm",
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
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
                      _getImage(),
                      width: 120,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 140,
                        color: const Color(0xFFE8D5D0),
                        child: const Icon(Icons.meeting_room, size: 50, color: Color(0xFF8D6E63)),
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
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
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
                          const SizedBox(height: 6),
                          Text(
                            "Available",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:  Colors.green.shade700, // Green
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1. Select Date
            const Text("1. Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD7CCC8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Select Date", style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                    Row(
                      children: [
                        Text(
                          _selectedDate != null
                              ? "${_getDayName(_selectedDate!.weekday)}, ${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}"
                              : "Not selected",
                          style: const TextStyle(fontSize: 14, color: Color(0xFF6D4C41)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, size: 18, color: Color(0xFF6D4C41)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Select Time
            const Text("2. Select Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
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
                          const Icon(Icons.access_time, size: 16, color: Color(0xFF6D4C41)),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD7CCC8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Color(0xFF6D4C41)),
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

            // 3. Duration - SHOW DURATION CLEARLY
            const Text("3. Duration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD7CCC8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total duration", style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                  Text(
                    _durationHours > 0 ? "$_durationHours hour${_durationHours != 1 ? 's' : ''}" : "Select time",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Booking Summary
            const Text("Booking Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
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
                        ? "${_startTime!.format(context)} - ${_endTime!.format(context)}"
                        : "Not selected",
                  ),
                  const SizedBox(height: 8),
                  _summaryRow("Duration", _durationHours > 0 ? "$_durationHours hour${_durationHours != 1 ? 's' : ''}" : "Not selected"),
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
                  backgroundColor: const Color(0xFF6D4C41),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm Booking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Text(
          value,
          style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFF6D4C41) : const Color(0xFF3E2723)
          ),
        ),
      ],
    );
  }
}