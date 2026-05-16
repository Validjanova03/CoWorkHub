import '../../database/db_helper.dart';

class PaymentHistoryService {
  final DBHelper _db = DBHelper();

  // Get payments with workspace/amenity name included
  Future<List<Map<String, dynamic>>> getPaymentsByUser(int userId) async {
    final dbClient = await _db.db;
    return await dbClient.rawQuery('''
  SELECT 
    p.*, 
    i.total, 
    i.issue_date,
    CASE 
      WHEN i.booking_id IS NULL THEN 'Membership Plan'
      ELSE r.name 
    END as resource_name
  FROM payment p
  JOIN invoice i ON p.invoice_id = i.invoice_id
  LEFT JOIN booking b ON i.booking_id = b.booking_id
  LEFT JOIN resources r ON b.resource_id = r.resource_id
  WHERE i.user_id = ?
  AND (
    i.booking_id IS NULL
    OR r.name IS NOT NULL
  )
  ORDER BY p.payment_date DESC
''', [userId]);

  }

}