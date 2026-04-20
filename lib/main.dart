import 'package:flutter/material.dart';
import 'ui_navigation/screens/login_screen.dart';
import 'database/db_helper.dart';


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
      home: LoginScreen(),
    );
  }
}