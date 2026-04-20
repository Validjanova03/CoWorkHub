class Invoice {
  final int? invoiceId;
  final int userId;
  final int? bookingId;
  final String issueDate;
  final String dueDate;
  final double discount;
  final double total;
  final String status;

  Invoice({
    this.invoiceId,
    required this.userId,
    this.bookingId,
    required this.issueDate,
    required this.dueDate,
    required this.discount,
    required this.total,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'invoice_id': invoiceId,
      'user_id': userId,
      'booking_id': bookingId,
      'issue_date': issueDate,
      'due_date': dueDate,
      'discount': discount,
      'total': total,
      'status': status,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      invoiceId: map['invoice_id'],
      userId: map['user_id'],
      bookingId: map['booking_id'],
      issueDate: map['issue_date'],
      dueDate: map['due_date'],
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: map['status'],
    );
  }
}