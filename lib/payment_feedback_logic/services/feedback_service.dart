import '../../database/db_helper.dart';
import '../models/feedback.dart';

class FeedbackService {
  final DBHelper _db = DBHelper();

  // Submit new feedback
  Future<void> submitFeedback({
    required int userId,
    required int resourceId,
    required double rating,
    required String message,
  }) async {
    final feedback = FeedbackModel(
      userId: userId,
      resourceId: resourceId,
      rating: rating,
      message: message,
      submittedAt: DateTime.now().toIso8601String(),
    );
    await _db.insertFeedback(feedback.toMap());
  }

  // Get average rating for a resource (workspace or amenity)
  Future<double> getAverageRating(int resourceId) async {
    final dbClient = await _db.db;
    final result = await dbClient.rawQuery('''
      SELECT AVG(rating) as avg_rating
      FROM feedback
      WHERE resource_id = ?
    ''', [resourceId]);
    final avg = result.first['avg_rating'];
    return avg != null ? (avg as double) : 0.0;
  }

  // Get all reviews for a resource with user names
  Future<List<Map<String, dynamic>>> getReviews(int resourceId) async {
    final dbClient = await _db.db;
    return await dbClient.rawQuery('''
      SELECT f.*, u.first_name, u.last_name
      FROM feedback f
      JOIN users u ON f.user_id = u.user_id
      WHERE f.resource_id = ?
      ORDER BY f.submitted_at DESC
    ''', [resourceId]);
  }
}