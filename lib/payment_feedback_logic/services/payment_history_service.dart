import '../../database/db_helper.dart';

class PaymentHistoryService {
  final DBHelper _db = DBHelper();

  // Get payments with workspace/amenity name included
  Future<List<Map<String, dynamic>>> getPaymentsByUser(int userId) async {
    final dbClient = await _db.db;
    return await dbClient.rawQuery('''
      SELECT p.*, i.total, i.issue_date, r.name as resource_name
      FROM payment p
      JOIN invoice i ON p.invoice_id = i.invoice_id
      JOIN booking b ON i.booking_id = b.booking_id
      JOIN resources r ON b.resource_id = r.resource_id
      WHERE i.user_id = ?
      ORDER BY p.payment_date DESC
    ''', [userId]);
  }
}