import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'booking_screen.dart';

class WorkspacesScreen extends StatefulWidget {
  final int userId;

  const WorkspacesScreen({super.key, required this.userId});

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> workspaces = [];

  @override
  void initState() {
    super.initState();
    loadWorkspaces();
  }

  Future<void> loadWorkspaces() async {
    List<Map<String, dynamic>> data = await dbHelper.getWorkspaces();
    setState(() {
      workspaces = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workspaces'),
        centerTitle: true,
      ),
      body: workspaces.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: workspaces.length,
        itemBuilder: (context, index) {
          final workspace = workspaces[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(workspace['name']),
              subtitle: Text(
                '${workspace['space_type']} | Capacity: ${workspace['capacity']} | Rate: ${workspace['rate']}',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        userId: widget.userId,
                        resourceId: workspace['resource_id'],
                        resourceName: workspace['name'],
                      ),
                    ),
                  );
                },
                child: Text('Book'),
              ),
            ),
          );
        },
      ),
    );
  }
}
