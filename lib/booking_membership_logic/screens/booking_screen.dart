import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'home_screen.dart';

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

    if (startTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Start time is required')),
      );
      return;
    }

    if (endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End time is required')),
      );
      return;
    }

    DateTime? startDateTime;
    DateTime? endDateTime;

    try {
      startDateTime = DateTime.parse(startTime);
      endDateTime = DateTime.parse(endTime);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid date format. Use: 2026-04-20 10:00:00',
          ),
        ),
      );
      return;
    }

    if (startDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Start time cannot be in the past')),
      );
      return;
    }

    if (!endDateTime.isAfter(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    await dbHelper.insertBooking({
      'user_id': widget.userId,
      'resource_id': widget.resourceId,
      'start_time': startDateTime.toString(),
      'end_time': endDateTime.toString(),
      'booking_status': 'Active',
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking created successfully')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(userId: widget.userId),
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
