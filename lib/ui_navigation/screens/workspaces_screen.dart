import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/ui_navigation/screens/workspace_details_screen.dart';
import 'package:coworkhub/payment_feedback_logic/widgets/rating_stars.dart';

class WorkspacesScreen extends StatefulWidget {
  final int userId;
  final String? initialFilter;

  const WorkspacesScreen({
    super.key,
    required this.userId,
    this.initialFilter,
  });

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  final DBHelper dbHelper = DBHelper();

  List<Map<String, dynamic>> workspaces = [];
  List<Map<String, dynamic>> allAmenities = [];
  Map<int, double> workspaceRatings = {};
  String selectedFilter = "All";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final workspaceData = await dbHelper.getWorkspaces();
    final amenityData = await dbHelper.getAmenities();

    final db = await dbHelper.db;
    Map<int, double> ratings = {};

    for (var workspace in workspaceData) {
      int resourceId = workspace['resource_id'];
      final ratingResult = await db.rawQuery(
        'SELECT AVG(rating) as avgRating FROM feedback WHERE resource_id = ?',
        [resourceId],
      );

      if (ratingResult.isNotEmpty && ratingResult.first['avgRating'] != null) {
        ratings[resourceId] = (ratingResult.first['avgRating'] as num).toDouble();
      } else {
        ratings[resourceId] = 0.0;
      }
    }

    setState(() {
      workspaces = workspaceData;
      allAmenities = amenityData;
      workspaceRatings = ratings;
      _isLoading = false;
    });

    if (widget.initialFilter != null && mounted) {
      setState(() {
        selectedFilter = widget.initialFilter!;
      });
    }
  }

  // NEW: Location method that matches HomeScreen logic but covers ALL workspaces
  String _getWorkspaceLocation(String name) {
    Map<String, String> locations = {
      // Hot Desks (5 total)
      'Hot Desk 1': 'Levent, Istanbul',
      'Hot Desk 2': 'Moda, Kadıköy, Istanbul',
      'Hot Desk 3': 'Kadiköy, Istanbul',
      'Hot Desk 4': 'Ataşehir, Istanbul',
      'Hot Desk 5': 'Maslak, Istanbul',

      // Dedicated Rooms (4 total)
      'Dedicated Room 1': 'Feneryolu, Kadıköy, Istanbul',
      'Dedicated Room 2': 'Beşiktaş, Istanbul',
      'Dedicated Room 3': 'Levent, Istanbul',
      'Dedicated Room 4': 'Bostancı, Istanbul',

      // Meeting Rooms (3 total)
      'Meeting Room 1': 'Şişli, Istanbul',
      'Meeting Room 2': 'Beşiktaş, Istanbul',
      'Meeting Room 3': 'Acıbadem, Istanbul',

      // Conference Halls (2 total)
      'Conference Hall 1': 'Şişli, Istanbul',
      'Conference Hall 2': 'Maslak, Istanbul',
    };
    return locations[name] ?? 'Istanbul, Turkey';
  }

  // NEW: Image method that matches HomeScreen exactly
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

  List<Map<String, dynamic>> get filteredWorkspaces {
    if (selectedFilter == "Available Now") {
      return workspaces.where((w) => w['availability_status'] == 'Available').toList();
    } else if (selectedFilter == "Hot Desk") {
      return workspaces.where((w) => w['space_type'] == 'Hot Desk').toList();
    } else if (selectedFilter == "Meeting") {
      return workspaces.where((w) => w['space_type'] == 'Meeting Room').toList();
    } else if (selectedFilter == "Conference") {
      return workspaces.where((w) => w['space_type'] == 'Conference Hall').toList();
    } else if (selectedFilter == "Private") {
      // FIXED: Changed from 'Dedicated Desk' to 'Dedicated Room'
      return workspaces.where((w) => w['space_type'] == 'Dedicated Room').toList();
    }
    return workspaces;
  }

  List<Map<String, dynamic>> get _availableAmenities {
    return allAmenities;
  }

  IconData _getAmenityIcon(String amenityType) {
    switch (amenityType) {
      case 'Printer':
        return Icons.print;
      case 'Projector':
        return Icons.videocam;
      case 'Kitchen':
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
      case 'Kitchen':
        return 'Coffee';
      case 'Locker':
        return 'Locker';
      default:
        return amenityType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ["All", "Available Now", "Hot Desk", "Meeting", "Conference", "Private"];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      appBar: AppBar(
        title: const Text(
          "Workspaces",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5D4037),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6D4C41)))
            : Column(
          children: [
            const SizedBox(height: 12),
            // Filter Chips
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final selected = selectedFilter == filters[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filters[index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF6D4C41) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? const Color(0xFF6D4C41) : const Color(0xFFD7CCC8),
                        ),
                      ),
                      child: Text(
                        filters[index],
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF3E2723),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Result count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${filteredWorkspaces.length} workspaces found",
                    style: const TextStyle(color: Color(0xFF8D6E63), fontSize: 12),
                  ),
                  const Text(
                    "Sort by: Recommended",
                    style: TextStyle(color: Color(0xFF8D6E63), fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Workspaces List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredWorkspaces.length,
                itemBuilder: (context, index) {
                  final w = filteredWorkspaces[index];
                  final workspaceRating = workspaceRatings[w['resource_id']] ?? 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD7CCC8)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            _getImageForWorkspace(w['name']),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: const Color(0xFFE8D5D0),
                                child: const Icon(Icons.meeting_room_rounded, size: 40, color: Color(0xFF8D6E63)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Location - NOW USING THE SAME METHOD AS HOMESCREEN
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF8D6E63)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _getWorkspaceLocation(w['name']),
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Rating
                              Row(
                                children: [
                                  RatingStars(rating: workspaceRating, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    workspaceRating.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF8D6E63)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Amenities
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: _availableAmenities.take(3).map((amenity) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF7F4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFD7CCC8)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getAmenityIcon(amenity['amenity_type']),
                                          size: 10,
                                          color: const Color(0xFF8D6E63),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          _getAmenityName(amenity['amenity_type']),
                                          style: const TextStyle(fontSize: 9, color: Color(0xFF6D4C41)),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // Price & Button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6D4C41).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "\$${w['rate']}/${w['unit_type']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6D4C41),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Availability badge
                            if (w['availability_status'] == 'Available')
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Available",
                                  style:  TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green.shade700,// Green
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WorkspaceDetailsScreen(
                                      userId: widget.userId,
                                      workspace: w,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6D4C41),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Book Now",
                                style: TextStyle(fontSize: 11, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}