import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int userId;

  const PaymentHistoryScreen({
    super.key, //use super.key instead of {Key? key}
    required this.userId,
  });

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final DBHelper _db = DBHelper();
  late Future<List<Map<String, dynamic>>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = _db.getPaymentsWithDetailsByUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No payments found.'));
          }
          final payments = snapshot.data!;
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Amount: \$${(p['total'] as num).toStringAsFixed(2)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Method: ${p['method']}'),
                      Text('Date: ${DateTime.parse(p['payment_date']).toLocal()}'),
                      Text('Status: ${p['status']}'),
                    ],
                  ),
                  trailing: Icon(
                    p['status'] == 'completed' ? Icons.check_circle : Icons.error,
                    color: p['status'] == 'completed' ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}