import 'package:flutter/material.dart';
import 'package:coworkhub/booking_membership_logic/screens/register_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workspace Booking App',
      home: RegisterScreen(),
    );
  }
}
