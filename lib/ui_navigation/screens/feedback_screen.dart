import 'package:flutter/material.dart';
import 'package:coworkhub/payment_feedback_logic/services/feedback_service.dart';
import 'package:coworkhub/ui_navigation/helper/workspace_helpers.dart';
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
  final FeedbackService feedbackService = FeedbackService();
  final TextEditingController _commentController = TextEditingController();

  double _rating = 0;
  bool _isLoading = false;


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
      await feedbackService.submitFeedback(
        userId: widget.userId,
        resourceId: widget.resourceId,
        rating: _rating,
        message: _commentController.text.trim(),
          );

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
                      WorkspaceHelpers.getImage(widget.resourceName),
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