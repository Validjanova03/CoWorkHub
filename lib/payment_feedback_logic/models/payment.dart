class Payment {
  final int? paymentId;
  final int invoiceId;
  final String paymentDate;
  final String method;
  final String status;

  Payment({
    this.paymentId,
    required this.invoiceId,
    required this.paymentDate,
    required this.method,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'payment_id': paymentId,
      'invoice_id': invoiceId,
      'payment_date': paymentDate,
      'method': method,
      'status': status,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      paymentId: map['payment_id'],
      invoiceId: map['invoice_id'],
      paymentDate: map['payment_date'],
      method: map['method'],
      status: map['status'],
    );
  }
}