import 'package:flutter/material.dart';
import 'membership_plans_screen.dart';
import 'workspace_screen.dart';
import 'my_bookings_screen.dart';

class HomeScreen extends StatelessWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => MembershipPlansScreen(userId: userId),
                  ),
                );
              },
              child: Text('Membership Plans'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => WorkspacesScreen(userId: userId),
                  ),
                );
              },
              child: Text('Workspaces'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => MyBookingsScreen(userId: userId),
                  ),
                );
              },
              child: Text('My Bookings'),
            ),
          ],
        ),
      ),
    );
  }
}