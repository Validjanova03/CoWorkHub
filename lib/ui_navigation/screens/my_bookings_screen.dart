import 'package:flutter/material.dart';
import 'package:coworkhub/booking_membership_logic/services/booking_service.dart';
import 'package:coworkhub/ui_navigation/helper/workspace_helpers.dart';
import 'package:coworkhub/ui_navigation/screens/payment_screen.dart';
import 'package:coworkhub/ui_navigation/helper/snackbar_helper.dart';

class MyBookingsScreen extends StatefulWidget {
  final int userId;
  final String userName;
  const MyBookingsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService bookingService = BookingService();
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);
    final data = await bookingService.getUserBookings(widget.userId);
    setState(() {
      bookings = data;
      isLoading = false;
    });

    for (final booking in data) {
      if (booking['booking_status'] == 'Active') {
        _checkAutoCancelBooking(booking);
      }
    }
  }

  void _checkAutoCancelBooking(Map<String, dynamic> booking) {
    final bookingId = booking['booking_id'] as int;
    final now = DateTime.now();
    final createdAt = DateTime.tryParse(booking['created_at'] ?? '') ?? now;
    final deadline = createdAt.add(const Duration(minutes: 10));

    if (now.isAfter(deadline)) {
      _autoCancelBooking(bookingId);
    } else {
      final remaining = deadline.difference(now);
      Future.delayed(remaining, () {
        if (mounted) {
          _autoCancelBooking(bookingId);
        }
      });
    }
  }

  Future<void> _autoCancelBooking(int bookingId) async {
    await bookingService.cancelBooking(bookingId);
    if (!mounted) return;
    _loadBookings();
    SnackbarHelper.showError(
      context,
      'Booking #$bookingId was automatically cancelled due to non-payment.',
    );
  }

  Future<void> _cancelBooking(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Cancel Booking",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
        ),
        content: const Text(
          "Are you sure you want to cancel this booking? This action cannot be undone.",
          style: TextStyle(fontSize: 13, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No, Keep It",
                style: TextStyle(color: Color(0xFF6D4C41))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Yes, Cancel",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await bookingService.cancelBooking(bookingId);
      if (!mounted) return;
      SnackbarHelper.showSuccess(context, 'Booking cancelled successfully');
      _loadBookings();
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    switch (_selectedTab) {
      case 0:
        return bookings.where((b) => b['booking_status'] == 'Active').toList();
      case 1:
        return bookings.where((b) => b['booking_status'] == 'confirmed').toList();
      case 2:
        return bookings.where((b) => b['booking_status'] == 'Cancelled').toList();
      default:
        return bookings;
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year} (${days[dt.weekday - 1]})";
    } catch (e) {
      return dateTime;
    }
  }

  String _formatTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return "$hour:$minute $period";
    } catch (e) {
      return dateTime;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      appBar: AppBar(
        title: const Text("My Booking",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5D4037),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF6D4C41)))
          : Column(
        children: [
          // Tabs
          Container(
            color: const Color(0xFF5D4037),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _tab("Upcoming", 0),
                  _tab("Completed", 1),
                  _tab("Cancelled", 2),
                ],
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadBookings,
              child: _filteredBookings.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "No ${["upcoming", "completed", "cancelled"][_selectedTab]} bookings",
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF8D6E63)),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredBookings.length,
                itemBuilder: (context, index) {
                  final booking = _filteredBookings[index];
                  if (_selectedTab == 0) {
                    return _upcomingCard(booking);
                  } else {
                    return _bookingCard(booking);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF5D4037) : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  // Big card for Upcoming tab — all Active bookings
  Widget _upcomingCard(Map<String, dynamic> booking) {
    final status = booking['booking_status'] ?? '';
    final resourceName = booking['resource_name'] ?? 'Workspace';
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orange warning banner
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Please complete payment within 10 minutes or your booking will be automatically cancelled.",
                    style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD7CCC8)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    WorkspaceHelpers.getImage(resourceName),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: const Color(0xFFE8D5D0),
                      child: const Icon(Icons.meeting_room_rounded,
                          size: 60, color: Color(0xFF8D6E63)),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            resourceName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(status)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _infoRow(Icons.location_on_outlined,
                          WorkspaceHelpers.getLocation(resourceName)),
                      const SizedBox(height: 4),
                      _infoRow(Icons.calendar_today_outlined,
                          _formatDateTime(booking['start_time'] ?? '')),
                      const SizedBox(height: 4),
                      _infoRow(Icons.access_time_outlined,
                          "${_formatTime(booking['start_time'] ?? '')} – ${_formatTime(booking['end_time'] ?? '')}"),
                      const SizedBox(height: 16),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _cancelBooking(booking['booking_id']),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text("Cancel Booking",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentScreen(
                                      bookingId: booking['booking_id'],
                                      userId: widget.userId,
                                      userName: widget.userName,
                                      resourceName:
                                      booking['resource_name'] ?? 'Workspace',
                                      date: _formatDateTime(
                                          booking['start_time'] ?? ''),
                                      startTime: null,
                                      endTime: null,
                                      capacity: 1,
                                      total: 0.0,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6D4C41),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text("Pay Now",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Small card for Completed and Cancelled tabs
  Widget _bookingCard(Map<String, dynamic> booking) {
    final status = booking['booking_status'] ?? '';
    final resourceName = booking['resource_name'] ?? 'Workspace';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              WorkspaceHelpers.getImage(resourceName),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: const Color(0xFFE8D5D0),
                child: const Icon(Icons.meeting_room,
                    size: 35, color: Color(0xFF8D6E63)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        resourceName,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(status)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _infoRow(Icons.location_on_outlined,
                    WorkspaceHelpers.getLocation(resourceName),
                    fontSize: 11),
                const SizedBox(height: 2),
                Text(
                  "${_formatDateTime(booking['start_time'] ?? '')} • ${_formatTime(booking['start_time'] ?? '')} – ${_formatTime(booking['end_time'] ?? '')}",
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF8D6E63)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {double fontSize = 12}) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF8D6E63)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, color: const Color(0xFF8D6E63)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}