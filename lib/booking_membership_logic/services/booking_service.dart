import 'package:coworkhub/database/db_helper.dart';

class BookingService {
  final DBHelper dbHelper = DBHelper();

  Future<bool> isTimeSlotAvailable({
    required int resourceId,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await dbHelper.db;

    final result = await db.rawQuery('''
      SELECT * FROM booking
      WHERE resource_id = ?
      AND booking_status != 'Cancelled'
      AND (
        (? < end_time) AND (? > start_time)
      )
    ''', [
      resourceId,
      start.toString(),
      end.toString(),
    ]);

    return result.isEmpty;
  }

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
      'created_at': DateTime.now().toString(), // ADD THIS
    });

    return bookingId;
  }

  Future<void> cancelBooking(int bookingId) async {
    await dbHelper.cancelBooking(bookingId);
  }

  Future<List<Map<String, dynamic>>> getBookingsByResource(int resourceId) async {
    return await dbHelper.getBookingsByResource(resourceId);
  }
}