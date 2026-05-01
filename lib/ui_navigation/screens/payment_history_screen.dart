import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/ui_navigation/screens/workspace_helpers.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int userId;

  const PaymentHistoryScreen({super.key, required this.userId});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  // ── Friend 3's logic ──
  final DBHelper db = DBHelper();
  late Future<List<Map<String, dynamic>>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = db.getPaymentsWithDetailsByUser(widget.userId);
  }

  // ── Your UI ──
  String _formatDate(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    } catch (e) {
      return dateTime;
    }
  }

  String _formatTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return "$hour:$minute $period";
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      appBar: AppBar(
        title: const Text("Payment History",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5D4037),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF6D4C41)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "No payments found",
                    style: TextStyle(
                        fontSize: 16, color: Color(0xFF8D6E63)),
                  ),
                ],
              ),
            );
          }

          final payments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              final status = p['status'] ?? 'unknown';
              final isPaid = status == 'completed';
              final resourceName = p['name'] ?? 'Workspace';
              final total = (p['total'] as num?)?.toDouble() ?? 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD7CCC8)),
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        WorkspaceHelpers.getImage(resourceName),
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 75,
                          height: 75,
                          color: const Color(0xFFE8D5D0),
                          child: const Icon(Icons.meeting_room,
                              size: 30, color: Color(0xFF8D6E63)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resourceName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 11, color: Color(0xFF8D6E63)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  WorkspaceHelpers.getLocation(resourceName),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8D6E63)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_formatDate(p['issue_date'] ?? '')} • ${_formatTime(p['issue_date'] ?? '')}",
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF8D6E63)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Amount & Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPaid ? "Paid" : "Failed",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isPaid ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 13, color: Color(0xFF8D6E63)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}