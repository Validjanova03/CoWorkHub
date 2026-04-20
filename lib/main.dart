import 'package:flutter/material.dart';
import 'package:coworkhub/ui_navigation/screens/login_screen.dart';
import 'package:coworkhub/ui_navigation/screens/register_screen.dart';
import 'package:coworkhub/ui_navigation/screens/home_screen.dart';
import 'package:coworkhub/ui_navigation/screens/workspaces_screen.dart';
void main() {
  runApp(const CoworkHubApp());
}

class CoworkHubApp extends StatelessWidget {
  const CoworkHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoworkHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF06B6D4),
          background: const Color(0xFFF9FAFB),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            elevation: 0,
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4F46E5),
            side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: Color(0xFF4F46E5), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade600),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      // ─── Only login route active for now ───
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),

        // ── Uncomment each route as you finish and test that screen ──
        '/register': (context) => const RegisterScreen(),
         '/home':     (context) => const HomeScreen(),
        '/workspaces':      (context) => const WorkspacesScreen(),
        // '/details':         (context) => const WorkspaceDetailsScreen(),
        // '/booking':         (context) => const BookingScreen(),
        // '/my-bookings':     (context) => const MyBookingsScreen(),
        // '/membership':      (context) => const MembershipScreen(),
        // '/payment':         (context) => const PaymentScreen(),
        // '/payment-history': (context) => const PaymentHistoryScreen(),
        // '/feedback':        (context) => const FeedbackScreen(),
        // '/amenities':       (context) => const AmenitiesScreen(),
      },
    );
  }
}