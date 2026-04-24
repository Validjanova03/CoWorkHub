import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/ui_navigation/screens/booking_screen.dart';
import 'package:coworkhub/ui_navigation/screens/feedback_screen.dart';
import 'package:coworkhub/payment_feedback_logic/widgets/rating_stars.dart';

class WorkspaceDetailsScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> workspace;

  const WorkspaceDetailsScreen({
    super.key,
    required this.userId,
    required this.workspace,
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
          ratingResult.first['count'] != null &&
          (ratingResult.first['count'] as int) > 0;

      if (hasReviews) {
        setState(() {
          rating = (ratingResult.first['avgRating'] as num).toDouble();
          reviewCount = (ratingResult.first['count'] as int);
          _reviews = reviewsResult;
        });
      } else {
        setState(() {
          rating = 0.0;
          reviewCount = 0;
          _reviews = [];
        });
      }

      setState(() {
        _amenities = allAmenities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String getImage() {
    final name = widget.workspace['name'] ?? '';

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

  IconData _getAmenityIcon(String amenityType) {
    switch (amenityType) {
      case 'Printer':
        return Icons.print;
      case 'Projector':
        return Icons.videocam;
      case 'Coffee machine':
        return Icons.coffee;
      case 'Locker':
        return Icons.lock;
      default:
        return Icons.star;
    }
  }

  String _getAmenityName(String amenityType) {
    switch (amenityType) {
      case 'Printer':
        return 'Printer';
      case 'Projector':
        return 'Projector';
      case 'Coffee machine':
        return 'Coffee';
      case 'Locker':
        return 'Locker';
      default:
        return amenityType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.workspace;
    final isAvailable = w['availability_status'] == 'Available';
    final capacity = w['capacity'] ?? 1;
    final rate = (w['rate'] ?? 0).toDouble();
    final spaceType = w['space_type'] ?? 'Workspace';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Stack(
            children: [
              Image.asset(
                getImage(),
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    width: double.infinity,
                    color: const Color(0xFFE8D5D0),
                    child: const Icon(Icons.meeting_room_rounded, size: 80, color: Color(0xFF8D6E63)),
                  );
                },
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAvailable ? "Available" : "Booked",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isAvailable ? Colors.green.shade700 : const Color(0xFF3E2723),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${rate.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6D4C41),
                              ),
                            ),
                            const Text(
                              "per hour",
                              style: TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF8D6E63)),
                            const SizedBox(width: 2),
                            const Text(
                              "Kadikoy, Istanbul",
                              style: TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (reviewCount > 0) ...[
                              RatingStars(rating: rating, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                "$rating ($reviewCount)",
                                style: const TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
                              ),
                            ] else ...[
                              const Icon(Icons.star_border, size: 12, color: Color(0xFF8D6E63)),
                              const SizedBox(width: 4),
                              const Text(
                                "No reviews yet",
                                style: TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: [
                        _infoChip(Icons.meeting_room, spaceType),
                        _infoChip(Icons.people, "$capacity people"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "About this room",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDescription(spaceType, w['name']),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Amenities",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: _amenities.map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getAmenityIcon(amenity['amenity_type']),
                                size: 12,
                                color: const Color(0xFF6D4C41),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getAmenityName(amenity['amenity_type']),
                                style: const TextStyle(fontSize: 10, color: Color(0xFF3E2723)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Room details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _detailRow("Room Type", spaceType),
                    _detailRow("Capacity", "$capacity people"),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reviews ($reviewCount)",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                        ),
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
                            minimumSize: const Size(50, 30),
                          ),
                          child: const Text(
                            "Write a Review",
                            style: TextStyle(fontSize: 12, color: Color(0xFF6D4C41)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_reviews.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "No reviews yet",
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ),
                      )
                    else
                      ..._reviews.map((review) => _reviewCard(review)),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isAvailable
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(
                                userId: widget.userId,
                                resourceId: w['resource_id'],
                                resourceName: w['name'],
                                rate: (w['rate'] ?? 0).toDouble(),
                                capacity: w['capacity'] ?? 1,
                                spaceType: w['space_type'] ?? 'Workspace',
                              ),
                            ),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D4C41),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Book Now",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
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
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3E2723))),
        ],
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final userName = "${review['first_name'] ?? ''} ${review['last_name'] ?? ''}".trim();
    final userInitial = userName.isNotEmpty ? userName[0] : "U";
    final reviewRating = (review['rating'] as num).toDouble();
    final reviewMessage = review['message'] ?? 'No comment';

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFE8D5D0),
            child: Text(userInitial, style: const TextStyle(fontSize: 11, color: Color(0xFF6D4C41))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName.isNotEmpty ? userName : "User",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 3),
                RatingStars(rating: reviewRating, size: 10),
                const SizedBox(height: 3),
                Text(
                  reviewMessage,
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

  String _getDescription(String type, String name) {
    switch (type) {
      case 'Hot Desk':
        return 'Flexible workspace ideal for freelancers with high-speed WiFi and ergonomic seating.';
      case 'Dedicated Room':
        return 'Personal desk designed for consistency, focus, and long-term work.';
      case 'Meeting Room':
        return 'Spacious meeting room perfect for team meetings and presentations.';
      case 'Conference Hall':
        return 'Large conference space suitable for events and workshops.';
      default:
        return 'Modern workspace designed for productivity and comfort.';
    }
  }
}