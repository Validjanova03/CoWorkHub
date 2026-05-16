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

    await dbHelper.insertMembership({
      'user_id': userId,
      'plan_id': planId,
      'start_date': DateTime.now().toString(),
      'end_date': DateTime.now().add(const Duration(days: 30)).toString(),
      'status': 'Active',
    });

    // Insert membership notification
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