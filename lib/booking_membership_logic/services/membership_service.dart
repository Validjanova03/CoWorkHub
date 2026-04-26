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

    return null;
  }

  Future<void> cancelMembership(int membershipId) async {
    await dbHelper.cancelMembership(membershipId);
  }
}