import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class MyBookingsScreen extends StatefulWidget {
  final int userId;

  const MyBookingsScreen({super.key, required this.userId});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    List<Map<String, dynamic>> data = await dbHelper.getBookings(widget.userId);
    setState(() {
      bookings = data;
    });
  }

  Future<void> cancelBooking(int bookingId) async {
    await dbHelper.cancelBooking(bookingId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking cancelled')),
    );
    loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        centerTitle: true,
      ),
      body: bookings.isEmpty
          ? Center(child: Text('No bookings found'))
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('Booking ID: ${booking['booking_id']}'),
              subtitle: Text(
                'Start: ${booking['start_time']}\n'
                    'End: ${booking['end_time']}\n'
                    'Status: ${booking['booking_status']}',
              ),
              trailing: ElevatedButton(
                onPressed: () => cancelBooking(booking['booking_id']),
                child: Text('Cancel'),
              ),
            ),
          );
        },
      ),
    );
  }
}
