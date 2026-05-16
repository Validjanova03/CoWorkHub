import 'package:coworkhub/database/db_helper.dart';

class MembershipService {
  final DBHelper dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> getPlans() async {
    return await dbHelper.getPlans();
  }

  Future<List<Map<String, dynamic>>> getUserMemberships(int userId) async {
    return await dbHelper.getMembershipByUser(userId);
  }

  Future<String?> subscribeToPlan({
    required int userId,
    required int planId,
  }) async {
    final memberships = await dbHelper.getMembershipByUser(userId);

    final hasActiveMembership = memberships.any(
          (membership) => membership['status'] == 'Active',
    );

    if (hasActiveMembership) {
      return 'User already has an active membership';
    }

    final plans = await dbHelper.getPlans();
    final selectedPlan = plans.firstWhere((p) => p['plan_id'] == planId);

    final invoiceId = await dbHelper.insertInvoice({
      'user_id': userId,
      'booking_id': null,
      'issue_date': DateTime.now().toString(),
      'due_date': DateTime.now().toString(),
      'discount': 0.0,
      'total': selectedPlan['price'],
      'status': 'paid',
    });

    await dbHelper.insertPayment({
      'invoice_id': invoiceId,
      'payment_date': DateTime.now().toString(),
      'method': 'Credit Card',
      'status': 'completed',
    });

    await dbHelper.insertMembership({
      'user_id': userId,
      'plan_id': planId,
      'start_date': DateTime.now().toString(),
      'end_date': DateTime.now().add(const Duration(days: 30)).toString(),
      'status': 'Active',
    });

    await dbHelper.insertNotification({
      'user_id': userId,
      'title': 'Membership Active',
      'message': 'Your membership plan is now active. Enjoy your benefits!',
      'icon_type': 'membership',
      'is_read': 0,
      'created_at': DateTime.now().toString(),
    });

    return null;
  }

  Future<void> cancelMembership(int membershipId) async {
    await dbHelper.cancelMembership(membershipId);
  }
}