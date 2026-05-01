import 'package:flutter/material.dart';
import 'package:coworkhub/ui_navigation/screens/workspace_details_screen.dart';
import 'package:coworkhub/payment_feedback_logic/widgets/rating_stars.dart';
import 'package:coworkhub/services/workspace_service.dart';
import 'package:coworkhub/payment_feedback_logic/services/feedback_service.dart';
import 'package:coworkhub/ui_navigation/helper/workspace_helpers.dart';

class WorkspacesScreen extends StatefulWidget {
  final int userId;
  final String? initialFilter;
  final String userName;

  const WorkspacesScreen({
    super.key,
    required this.userId,
    this.initialFilter,
    required this.userName,
  });

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  final WorkspaceService workspaceService = WorkspaceService();
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

    final workspaceData = await workspaceService.getWorkspaces();
    final amenityData = await workspaceService.getAmenities();
    final FeedbackService feedbackService = FeedbackService();
    Map<int, double> ratings = {};
    for (var workspace in workspaceData) {
      int resourceId = workspace['resource_id'];
      ratings[resourceId] = await feedbackService.getAverageRating(resourceId);
    }

    setState(() {
      workspaces = workspaceData;
      allAmenities = amenityData;
      workspaceRatings = ratings;
      _isLoading = false;
      if (widget.initialFilter != null) {
        selectedFilter = widget.initialFilter!;
      }
    });
  }

  List<Map<String, dynamic>> get filteredWorkspaces {
    switch (selectedFilter) {
      case "Available Now":
        return workspaces.where((w) => w['availability_status'] == 'Available').toList();
      case "Hot Desk":
        return workspaces.where((w) => w['space_type'] == 'Hot Desk').toList();
      case "Meeting":
        return workspaces.where((w) => w['space_type'] == 'Meeting Room').toList();
      case "Conference":
        return workspaces.where((w) => w['space_type'] == 'Conference Hall').toList();
      case "Dedicated Room":
        return workspaces.where((w) => w['space_type'] == 'Dedicated Room').toList();
      default:
        return workspaces;
    }
  }

  IconData _getAmenityIcon(String type) {
    const icons = {
      'Printer': Icons.print,
      'Projector': Icons.videocam,
      'Kitchen': Icons.coffee,
      'Locker': Icons.lock,
    };
    return icons[type] ?? Icons.star;
  }

  String _getAmenityName(String type) {
    const names = {
      'Printer': 'Printer',
      'Projector': 'Projector',
      'Kitchen': 'Coffee',
      'Locker': 'Locker',
    };
    return names[type] ?? type;
  }

  void _navigateToDetails(Map<String, dynamic> w) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkspaceDetailsScreen(
          userId: widget.userId,
          workspace: w,
          userName: widget.userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ["All", "Available Now", "Hot Desk", "Meeting", "Conference", "Dedicated Room"];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      appBar: AppBar(
        title: const Text("Workspaces", style: TextStyle(color: Colors.white)),
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
                    onTap: () => setState(() => selectedFilter = filters[index]),
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
                            WorkspaceHelpers.getImage(w['name']),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: const Color(0xFFE8D5D0),
                              child: const Icon(Icons.meeting_room_rounded,
                                  size: 40, color: Color(0xFF8D6E63)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color(0xFF3E2723))),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 12, color: Color(0xFF8D6E63)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      WorkspaceHelpers.getLocation(w['name']),
                                      style: const TextStyle(
                                          fontSize: 11, color: Color(0xFF8D6E63)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  RatingStars(rating: workspaceRating, size: 14),
                                  const SizedBox(width: 6),
                                  Text(workspaceRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontSize: 12, color: Color(0xFF8D6E63))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: allAmenities.take(3).map((amenity) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF7F4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFD7CCC8)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_getAmenityIcon(amenity['amenity_type']),
                                            size: 10, color: const Color(0xFF8D6E63)),
                                        const SizedBox(width: 3),
                                        Text(_getAmenityName(amenity['amenity_type']),
                                            style: const TextStyle(
                                                fontSize: 9, color: Color(0xFF6D4C41))),
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
                                    color: Color(0xFF6D4C41)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (w['availability_status'] == 'Available')
                              Text("Available",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade700)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _navigateToDetails(w),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6D4C41),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("Book Now",
                                  style: TextStyle(fontSize: 11, color: Colors.white)),
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