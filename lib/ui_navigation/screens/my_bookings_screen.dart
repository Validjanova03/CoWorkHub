import 'package:flutter/material.dart';
import 'package:coworkhub/booking_membership_logic/services/booking_service.dart';
import 'package:coworkhub/ui_navigation/screens/workspace_helpers.dart';

class MyBookingsScreen extends StatefulWidget {
  final int userId;

  const MyBookingsScreen({super.key, required this.userId});

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
  }

  Future<void> _cancelBooking(int bookingId) async {
    await bookingService.cancelBooking(bookingId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking cancelled')),
    );
    _loadBookings();
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
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
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
                color: Colors.white.withOpacity(0.15),
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
                  final isFirst = index == 0 && _selectedTab == 0;
                  return isFirst
                      ? _featuredBookingCard(booking)
                      : _bookingCard(booking);
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

  Widget _featuredBookingCard(Map<String, dynamic> booking) {
    final status = booking['booking_status'] ?? '';
    final resourceName = booking['name'] ?? 'Workspace';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Booking",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
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
                // Image
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
                    errorBuilder: (_, __, ___) => Container(
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
                              color: _getStatusColor(status).withOpacity(0.1),
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
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFFD7CCC8)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                              child: const Text("View Details",
                                  style: TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _cancelBooking(booking['booking_id']),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                              child: const Text("Cancel Booking",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 13)),
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

          // All Bookings header
          if (_filteredBookings.length > 1) ...[
            const SizedBox(height: 20),
            const Text(
              "All Bookings",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E2723)),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking) {
    final status = booking['booking_status'] ?? '';
    final resourceName = booking['name'] ?? 'Workspace';

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
              errorBuilder: (_, __, ___) => Container(
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
                        color: _getStatusColor(status).withOpacity(0.1),
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
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: Color(0xFF8D6E63)),
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