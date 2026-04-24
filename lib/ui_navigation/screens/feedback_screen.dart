import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/payment_feedback_logic/widgets/rating_stars.dart';

class FeedbackScreen extends StatefulWidget {
  final int userId;
  final int resourceId;
  final String resourceName;

  const FeedbackScreen({
    super.key,
    required this.userId,
    required this.resourceId,
    required this.resourceName,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final DBHelper dbHelper = DBHelper();
  final TextEditingController _commentController = TextEditingController();

  double _rating = 0;
  bool _isLoading = false;

  String _getImageForWorkspace(String name) {
    if (name.contains('Hot Desk')) {
      if (name == 'Hot Desk 1') return 'assets/images/hot_desk.jpg';
      if (name == 'Hot Desk 2') return 'assets/images/hot_desk2.png';
      if (name == 'Hot Desk 3') return 'assets/images/hot_desk_3.png';
      if (name == 'Hot Desk 4') return 'assets/images/hot_desk_4.png';
      if (name == 'Hot Desk 5') return 'assets/images/hot_desk_5.png';
      return 'assets/images/hot_desk.png';
    }

    if (name.contains('Dedicated Room')) {
      if (name == 'Dedicated Room 1') return 'assets/images/dedicated_desk.jpg';
      if (name == 'Dedicated Room 2') return 'assets/images/dedicated_desk2.png';
      if (name == 'Dedicated Room 3') return 'assets/images/dedicated_room_3.png';
      if (name == 'Dedicated Room 4') return 'assets/images/dedicated_desk_4.png';
      return 'assets/images/dedicated_desk.png';
    }

    if (name.contains('Meeting Room')) {
      if (name == 'Meeting Room 1') return 'assets/images/meeting_room.jpg';
      if (name == 'Meeting Room 2') return 'assets/images/meeting_room2.png';
      if (name == 'Meeting Room 3') return 'assets/images/meeting_room_3.png';
      return 'assets/images/meeting_room.png';
    }

    if (name.contains('Conference Hall')) {
      if (name == 'Conference Hall 1') return 'assets/images/conference_hall.jpg';
      if (name == 'Conference Hall 2') return 'assets/images/conference_hall2.png';
      return 'assets/images/conference_hall.png';
    }

    return 'assets/images/workspace.png';
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await dbHelper.insertFeedback({
        'user_id': widget.userId,
        'resource_id': widget.resourceId,
        'rating': _rating,
        'message': _commentController.text.trim(),
        'submitted_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text(
          "Write a Review",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5D4037),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workspace card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD7CCC8)),
              ),
              child: Column(
                children: [
                  // BIG IMAGE at the top - same border radius as white box (16)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16), // Same as white container
                    child: Image.asset(
                      _getImageForWorkspace(widget.resourceName),
                      width: double.infinity,
                      height: 180, // Much bigger!
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 180,
                          color: const Color(0xFFE8D5D0),
                          child: const Icon(Icons.meeting_room_rounded, size: 60, color: Color(0xFF8D6E63)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reviewing text below image
                  Row(
                    children: [
                      const Text(
                        "Reviewing:",
                        style: TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.resourceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rating section
            const Text(
              "How would you rate this workspace?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  RatingStars(rating: _rating, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    _rating == 0 ? "Tap the buttons below to rate" : "${_rating.toStringAsFixed(0)} stars",
                    style: TextStyle(
                      fontSize: 14,
                      color: _rating == 0 ? const Color(0xFF9CA3AF) : const Color(0xFF6D4C41),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ratingButton(1),
                _ratingButton(2),
                _ratingButton(3),
                _ratingButton(4),
                _ratingButton(5),
              ],
            ),
            const SizedBox(height: 24),

            // Comment section
            const Text(
              "Share your experience",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD7CCC8)),
              ),
              child: TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "What did you like? What could be improved?",
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Submit Feedback",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _ratingButton(int value) {
    final isSelected = _rating == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _rating = value.toDouble();
        });
      },
      child: Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6D4C41) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF6D4C41) : const Color(0xFFD7CCC8),
          ),
        ),
        child: Center(
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF3E2723),
            ),
          ),
        ),
      ),
    );
  }
}