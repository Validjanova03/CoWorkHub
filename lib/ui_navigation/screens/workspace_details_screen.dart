import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/ui_navigation/screens/booking_screen.dart';
import 'package:coworkhub/ui_navigation/screens/feedback_screen.dart';
import 'package:coworkhub/payment_feedback_logic/widgets/rating_stars.dart';
import 'package:coworkhub/ui_navigation/screens/workspace_helpers.dart';

class WorkspaceDetailsScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> workspace;
  final String userName;

  const WorkspaceDetailsScreen({
    super.key,
    required this.userId,
    required this.workspace,
    required this.userName,
  });

  @override
  State<WorkspaceDetailsScreen> createState() => _WorkspaceDetailsScreenState();
}

class _WorkspaceDetailsScreenState extends State<WorkspaceDetailsScreen> {
  final DBHelper dbHelper = DBHelper();
  double rating = 0.0;
  int reviewCount = 0;
  List<Map<String, dynamic>> _amenities = [];
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final allAmenities = await dbHelper.getAmenities();
      final db = await dbHelper.db;

      final ratingResult = await db.rawQuery(
        'SELECT AVG(rating) as avgRating, COUNT(rating) as count FROM feedback WHERE resource_id = ?',
        [widget.workspace['resource_id']],
      );

      final reviewsResult = await db.rawQuery(
        'SELECT f.*, u.first_name, u.last_name FROM feedback f '
            'JOIN users u ON f.user_id = u.user_id '
            'WHERE f.resource_id = ? ORDER BY f.submitted_at DESC LIMIT 3',
        [widget.workspace['resource_id']],
      );

      final hasReviews = ratingResult.isNotEmpty &&
          ratingResult.first['avgRating'] != null &&
          (ratingResult.first['count'] as int) > 0;

      setState(() {
        rating = hasReviews ? (ratingResult.first['avgRating'] as num).toDouble() : 0.0;
        reviewCount = hasReviews ? (ratingResult.first['count'] as int) : 0;
        _reviews = hasReviews ? reviewsResult : [];
        _amenities = allAmenities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  IconData _getAmenityIcon(String type) {
    const icons = {
      'Printer': Icons.print,
      'Projector': Icons.videocam,
      'Coffee machine': Icons.coffee,
      'Locker': Icons.lock,
    };
    return icons[type] ?? Icons.star;
  }

  String _getAmenityName(String type) {
    const names = {
      'Printer': 'Printer',
      'Projector': 'Projector',
      'Coffee machine': 'Coffee',
      'Locker': 'Locker',
    };
    return names[type] ?? type;
  }

  String _getDescription(String type) {
    const descriptions = {
      'Hot Desk': 'Flexible workspace ideal for freelancers with high-speed WiFi and ergonomic seating.',
      'Dedicated Room': 'Personal desk designed for consistency, focus, and long-term work.',
      'Meeting Room': 'Spacious meeting room perfect for team meetings and presentations.',
      'Conference Hall': 'Large conference space suitable for events and workshops.',
    };
    return descriptions[type] ?? 'Modern workspace designed for productivity and comfort.';
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.workspace;
    final isAvailable = w['availability_status'] == 'Available';
    final capacity = w['capacity'] ?? 1;
    final rate = (w['rate'] ?? 0).toDouble();
    final spaceType = w['space_type'] ?? 'Workspace';
    final name = w['name'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Stack(
            children: [
              Image.asset(
                WorkspaceHelpers.getImage(name),
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 280,
                  width: double.infinity,
                  color: const Color(0xFFE8D5D0),
                  child: const Icon(Icons.meeting_room_rounded,
                      size: 80, color: Color(0xFF8D6E63)),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3E2723))),
                              const SizedBox(height: 4),
                              Text(
                                isAvailable ? "Available" : "Booked",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isAvailable
                                        ? Colors.green.shade700
                                        : const Color(0xFF3E2723)),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("\$${rate.toStringAsFixed(0)}",
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6D4C41))),
                            const Text("per hour",
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF8D6E63))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Location & Rating
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 12, color: Color(0xFF8D6E63)),
                            const SizedBox(width: 2),
                            Text(WorkspaceHelpers.getLocation(name),
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF8D6E63))),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: reviewCount > 0
                              ? [
                            RatingStars(rating: rating, size: 12),
                            const SizedBox(width: 4),
                            Text("$rating ($reviewCount)",
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF8D6E63))),
                          ]
                              : [
                            const Icon(Icons.star_border,
                                size: 12, color: Color(0xFF8D6E63)),
                            const SizedBox(width: 4),
                            const Text("No reviews yet",
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF8D6E63))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Info Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: [
                        _infoChip(Icons.meeting_room, spaceType),
                        _infoChip(Icons.people, "$capacity people"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // About
                    const Text("About this room",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723))),
                    const SizedBox(height: 8),
                    Text(_getDescription(spaceType),
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.4)),
                    const SizedBox(height: 24),

                    // Amenities
                    const Text("Amenities",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723))),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: _amenities.map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getAmenityIcon(amenity['amenity_type']),
                                  size: 12, color: const Color(0xFF6D4C41)),
                              const SizedBox(width: 4),
                              Text(_getAmenityName(amenity['amenity_type']),
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFF3E2723))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Room Details
                    const Text("Room details",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723))),
                    const SizedBox(height: 10),
                    _detailRow("Room Type", spaceType),
                    _detailRow("Capacity", "$capacity people"),
                    const SizedBox(height: 24),

                    // Reviews
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Reviews ($reviewCount)",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723))),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FeedbackScreen(
                                  userId: widget.userId,
                                  resourceId: widget.workspace['resource_id'],
                                  resourceName: widget.workspace['name'],
                                ),
                              ),
                            ).then((_) => _loadData());
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30)),
                          child: const Text("Write a Review",
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF6D4C41))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _reviews.isEmpty
                        ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text("No reviews yet",
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                      ),
                    )
                        : Column(
                      children: _reviews.map((r) => _reviewCard(r)).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Book Now Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isAvailable
                            ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(
                              userId: widget.userId,
                              resourceId: w['resource_id'],
                              resourceName: w['name'],
                              rate: rate,
                              capacity: capacity,
                              spaceType: spaceType,
                              userName: widget.userName,
                            ),
                          ),
                        )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D4C41),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Book Now",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF6D4C41)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF3E2723))),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3E2723))),
        ],
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final userName =
    "${review['first_name'] ?? ''} ${review['last_name'] ?? ''}".trim();
    final reviewRating = (review['rating'] as num).toDouble();

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFE8D5D0),
            child: Text(
              userName.isNotEmpty ? userName[0] : "U",
              style: const TextStyle(fontSize: 11, color: Color(0xFF6D4C41)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName.isNotEmpty ? userName : "User",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 3),
                RatingStars(rating: reviewRating, size: 10),
                const SizedBox(height: 3),
                Text(
                  review['message'] ?? 'No comment',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}