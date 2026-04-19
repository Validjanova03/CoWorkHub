import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'booking_membership_logic/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // keep DB initialization (your part)
  DBHelper dbHelper = DBHelper();
  await dbHelper.db;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workspace Booking App',
      home: RegisterScreen(), // keep teammate UI
    );
  }
}