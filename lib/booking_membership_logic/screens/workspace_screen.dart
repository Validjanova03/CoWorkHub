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
      return workspaces.where((w) => w['space_type'] == 'Dedicated Desk').toList();
    }
    return workspaces;
  }

  List<Map<String, dynamic>> get _availableAmenities {
    return allAmenities;
  }

  String getImage(String type, String name) {
    switch (type) {
      case 'Hot Desk':
        return 'assets/hot_desk.jpg';
      case 'Dedicated Desk':
        return 'assets/dedicated_desk.jpg';
      case 'Meeting Room':
        return 'assets/meeting_room.jpg';
      case 'Conference Hall':
        return 'assets/conference_hall.jpg';
      default:
        return 'assets/workspace.jpg';
    }
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
      appBar: AppBar(
        title: const Text("Workspaces"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
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
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF6D4C41) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filters[index],
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${filteredWorkspaces.length} workspaces found"),
                  const Text("Sort by: Recommended"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredWorkspaces.length,
                itemBuilder: (context, index) {
                  final w = filteredWorkspaces[index];
                  final workspaceRating = workspaceRatings[w['resource_id']] ?? 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            getImage(w['space_type'], w['name']),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 90,
                                height: 90,
                                color: const Color(0xFFE8D5D0),
                                child: const Icon(Icons.meeting_room_rounded, size: 40, color: Color(0xFF8D6E63)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 12),
                                  const SizedBox(width: 3),
                                  const Text("Kadıköy, Istanbul", style: TextStyle(fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  RatingStars(rating: workspaceRating, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    workspaceRating.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                children: _availableAmenities.take(2).map((amenity) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getAmenityIcon(amenity['amenity_type']),
                                          size: 10,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          _getAmenityName(amenity['amenity_type']),
                                          style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${w['rate']}/${w['unit_type']}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "View Details",
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