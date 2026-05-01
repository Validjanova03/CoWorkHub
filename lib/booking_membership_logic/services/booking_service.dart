import 'package:coworkhub/database/db_helper.dart';

class BookingService {
  final DBHelper dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> getUserBookings(int userId) async {
    return await dbHelper.getBookingsWithResourceByUser(userId);
  }

  Future<dynamic> createBooking({
    required int userId,
    required int resourceId,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    if (startDateTime.isBefore(DateTime.now())) {
      return 'Start time cannot be in the past';
    }

    if (!endDateTime.isAfter(startDateTime)) {
      return 'End time must be after start time';
    }

    final conflicts = await dbHelper.checkConflictingBookings(
      resourceId,
      startDateTime.toString(),
      endDateTime.toString(),
    );

    if (conflicts.isNotEmpty) {
      return 'This workspace is already booked for that time';
    }

    var bookingId = await dbHelper.insertBooking({
      'user_id': userId,
      'resource_id': resourceId,
      'start_time': startDateTime.toString(),
      'end_time': endDateTime.toString(),
      'booking_status': 'Active',
    });

    return bookingId;
  }

  Future<void> cancelBooking(int bookingId) async {
    await dbHelper.cancelBooking(bookingId);
  }
}