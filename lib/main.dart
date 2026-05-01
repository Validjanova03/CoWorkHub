import 'package:flutter/material.dart';
import 'package:coworkhub/ui_navigation/screens/welcome_screen.dart';
import 'package:coworkhub/ui_navigation/screens/login_screen.dart';
import 'package:coworkhub/ui_navigation/screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: Colors.brown,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
      ),

      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[900],
      ),

      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const WelcomeScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}