import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'my_bookings_screen.dart';

class BookingScreen extends StatefulWidget {
  final int userId;
  final int resourceId;
  final String resourceName;

  const BookingScreen({
    super.key,
    required this.userId,
    required this.resourceId,
    required this.resourceName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final DBHelper dbHelper = DBHelper();

  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  Future<void> createBooking() async {
    String startTime = startTimeController.text.trim();
    String endTime = endTimeController.text.trim();

    if (startTime.isEmpty || endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill booking time fields')),
      );
      return;
    }

    await dbHelper.insertBooking({
      'user_id': widget.userId,
      'resource_id': widget.resourceId,
      'start_time': startTime,
      'end_time': endTime,
      'booking_status': 'Active',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking created successfully')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyBookingsScreen(userId: widget.userId),
      ),
    );
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Resource: ${widget.resourceName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: startTimeController,
              decoration: InputDecoration(
                labelText: 'Start Time (example: 2026-04-20 10:00)',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: endTimeController,
              decoration: InputDecoration(
                labelText: 'End Time (example: 2026-04-20 12:00)',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createBooking,
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}