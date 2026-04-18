import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'workspaces_screen.dart';

class MembershipPlansScreen extends StatefulWidget {
  final int userId;

  const MembershipPlansScreen({super.key, required this.userId});

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> plans = [];

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    List<Map<String, dynamic>> data = await dbHelper.getPlans();
    setState(() {
      plans = data;
    });
  }

  Future<void> subscribeToPlan(int planId) async {
    await dbHelper.insertMembership({
      'user_id': widget.userId,
      'plan_id': planId,
      'start_date': DateTime.now().toString(),
      'end_date': DateTime.now().add(Duration(days: 30)).toString(),
      'status': 'Active',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membership subscribed successfully')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkspacesScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membership Plans'),
        centerTitle: true,
      ),
      body: plans.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(plan['plan_name']),
              subtitle: Text(
                'Price: ${plan['price']} | Discount: ${plan['discount_applied']}%',
              ),
              trailing: ElevatedButton(
                onPressed: () => subscribeToPlan(plan['plan_id']),
                child: Text('Subscribe'),
              ),
            ),
          );
        },
      ),
    );
  }
}
