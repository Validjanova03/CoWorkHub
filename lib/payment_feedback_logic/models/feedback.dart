class FeedbackModel {
  final int? feedbackId;
  final int userId;
  final int resourceId;
  final double rating;
  final String message;
  final String submittedAt;

  FeedbackModel({
    this.feedbackId,
    required this.userId,
    required this.resourceId,
    required this.rating,
    required this.message,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'feedback_id': feedbackId,
      'user_id': userId,
      'resource_id': resourceId,
      'rating': rating,
      'message': message,
      'submitted_at': submittedAt,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      feedbackId: map['feedback_id'],
      userId: map['user_id'],
      resourceId: map['resource_id'],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      message: map['message'],
      submittedAt: map['submitted_at'],
    );
  }
}