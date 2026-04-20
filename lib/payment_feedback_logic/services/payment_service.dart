import '../../database/db_helper.dart';
import '../models/invoice.dart';
import '../models/payment.dart';

class PaymentService {
  final DBHelper _db = DBHelper();

  // Calculate total cost for a booking based on resource rate and duration
  Future<double> calculateBookingCost(int bookingId) async {
    final booking = await _db.getBookingById(bookingId);
    if (booking == null) throw Exception('Booking not found');

    final resource = await _db.getResourceById(booking['resource_id']);
    if (resource == null) throw Exception('Resource not found');

    double rate = (resource['rate'] as num).toDouble();
    String unitType = resource['unit_type'];

    DateTime start = DateTime.parse(booking['start_time']);
    DateTime end = DateTime.parse(booking['end_time']);
    double hours = end.difference(start).inMinutes / 60.0;

    switch (unitType) {
      case 'Hour':
        return rate * hours;
      case 'Page':
      // For printer – assume 10 pages per booking (or could be passed from UI)
        return rate * 10;
      case 'Unit':
        return rate;
      default:
        return rate * hours;
    }
  }

  // Generate invoice for a specific booking
  Future<Invoice> generateInvoiceForBooking(int bookingId, int userId) async {
    double total = await calculateBookingCost(bookingId);
    String issueDate = DateTime.now().toIso8601String();
    String dueDate = DateTime.now().add(const Duration(days: 7)).toIso8601String();

    final invoice = Invoice(
      userId: userId,
      bookingId: bookingId,
      issueDate: issueDate,
      dueDate: dueDate,
      discount: 0.0,
      total: total,
      status: 'pending',
    );

    int id = await _db.insertInvoice(invoice.toMap());
    // Return invoice with the new ID
    return Invoice(
      invoiceId: id,
      userId: userId,
      bookingId: bookingId,
      issueDate: issueDate,
      dueDate: dueDate,
      discount: 0.0,
      total: total,
      status: 'pending',
    );
  }

  // Process payment for an invoice
  Future<bool> processPayment(int invoiceId, String method) async {
    final paymentDate = DateTime.now().toIso8601String();
    final payment = Payment(
      invoiceId: invoiceId,
      paymentDate: paymentDate,
      method: method,
      status: 'completed',
    );

    await _db.insertPayment(payment.toMap());
    await _db.updateInvoiceStatus(invoiceId, 'paid');

    // Update booking status if invoice has booking_id
    final invoiceMap = await _db.getInvoiceById(invoiceId);
    if (invoiceMap != null && invoiceMap['booking_id'] != null) {
      await _db.updateBookingStatus(invoiceMap['booking_id'], 'confirmed');
    }

    return true;
  }
}