import 'package:flutter/material.dart';
import 'package:coworkhub/services/workspace_service.dart';
import 'package:coworkhub/ui_navigation/screens/workspaces_screen.dart';
import 'package:coworkhub/ui_navigation/screens/workspace_details_screen.dart';
import 'package:coworkhub/payment_feedback_logic/widgets/rating_stars.dart';
import 'package:coworkhub/ui_navigation/screens/my_bookings_screen.dart';
import 'package:coworkhub/ui_navigation/screens/payment_history_screen.dart';
import 'package:coworkhub/ui_navigation/screens/profile_screen.dart';
import 'package:coworkhub/ui_navigation/screens/notification_screen.dart';
import 'package:coworkhub/ui_navigation/helper/workspace_helpers.dart';
import 'package:coworkhub/payment_feedback_logic/services/feedback_service.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  List<Map<String, dynamic>> _allWorkspaces = [];
  bool _isLoading = true;
  String _greeting = "";
  Map<int, double> _workspaceRatings = {}; // ← add this
  final FeedbackService feedbackService = FeedbackService();

  IconData _getGreetingIcon() {
    int hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny;
    if (hour < 18) return Icons.wb_cloudy;
    return Icons.nights_stay;
  }

  @override
  void initState() {
    super.initState();
    _loadWorkspaces();
    _updateGreeting();
  }

  void _updateGreeting() {
    int hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) _greeting = "Good Morning";
      else if (hour < 18) _greeting = "Good Afternoon";
      else _greeting = "Good Evening";
    });
  }

  Future<void> _loadWorkspaces() async {
    setState(() => _isLoading = true);
    try {
      final workspaceService = WorkspaceService();
      _allWorkspaces = await workspaceService.getWorkspaces();

      // Load ratings
      for (var workspace in _allWorkspaces) {
        int resourceId = workspace['resource_id'];
        _workspaceRatings[resourceId] =
        await feedbackService.getAverageRating(resourceId);
        print('Resource: ${workspace['name']} Rating: ${_workspaceRatings[resourceId]}');
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error: $e');
    }
  }

  String getInitials() {
    List<String> names = widget.userName.split(" ");
    if (names.isEmpty) return "U";
    if (names.length == 1) return names[0][0].toUpperCase();
    return "${names[0][0]}${names[1][0]}".toUpperCase();
  }

  void _goToCategory(String filterType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkspacesScreen(
          userId: widget.userId,
          initialFilter: filterType,
          userName: widget.userName,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _featuredWorkspaces {
    final types = ['Hot Desk', 'Dedicated Room', 'Meeting Room', 'Conference Hall'];
    return types.map((type) => _allWorkspaces
        .firstWhere((w) => w['space_type'] == type, orElse: () => {}))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> get _popularWorkspaces {
    if (_allWorkspaces.length < 4) return _allWorkspaces;
    return [
      _allWorkspaces[1],  // Hot Desk 2
      _allWorkspaces[5],  // Dedicated Room 1
      _allWorkspaces[8],  // Meeting Room 2
      _allWorkspaces[11], // Conference Hall 1
    ];
  }

  List<Map<String, dynamic>> get _availableWorkspaces {
    return _allWorkspaces
        .where((w) => w['availability_status'] == 'Available')
        .take(3)
        .toList();
  }

  List<Map<String, dynamic>> get _filteredWorkspaces {
    if (searchQuery.isEmpty) return [];
    return _allWorkspaces.where((workspace) {
      final name = workspace['name']?.toLowerCase() ?? '';
      final type = workspace['space_type']?.toLowerCase() ?? '';
      return name.contains(searchQuery) || type.contains(searchQuery);
    }).toList();
  }

  void _navigateToDetails(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkspaceDetailsScreen(
          workspace: item,
          userId: widget.userId,
          userName: widget.userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      WorkspacesScreen(userId: widget.userId, userName: widget.userName),
      MyBookingsScreen(userId: widget.userId, userName: widget.userName,),
      PaymentHistoryScreen(userId: widget.userId),
      ProfileScreen(
        userId: widget.userId,
        userName: widget.userName,
        initials: getInitials(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6D4C41)))
          : pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6D4C41),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_outlined),
            activeIcon: Icon(Icons.meeting_room_rounded),
            label: "Spaces",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today_rounded),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            activeIcon: Icon(Icons.history_rounded),
            label: "Payments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF5D4037),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_greeting,
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(width: 6),
                        Icon(_getGreetingIcon(),
                            color: Colors.amber.shade400, size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.userName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                        SizedBox(width: 4),
                        Text("Istanbul, Kadiköy",
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 26),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ));
                      },
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFD7CCC8)),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) =>
                    setState(() => searchQuery = value.toLowerCase()),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF8D6E63)),
                  hintText: "Search workspaces...",
                  hintStyle: TextStyle(color: Color(0xFF8D6E63)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _category(Icons.laptop_mac_rounded, "Hot Desk", "Hot Desk"),
                _category(Icons.groups_rounded, "Meeting", "Meeting"),
                _category(Icons.present_to_all_rounded, "Conference", "Conference"),
                _category(Icons.lock_outline_rounded, "Dedicated", "Dedicated Room"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (searchQuery.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Explore Workspaces",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2723))),
                  SizedBox(height: 4),
                  Text("Find the best spaces for your productivity",
                      style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Featured
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Featured Workspaces",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2723))),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _featuredWorkspaces.length,
                itemBuilder: (context, index) =>
                    _workspaceCard(_featuredWorkspaces[index]),
              ),
            ),
            const SizedBox(height: 20),

            // Popular
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Popular Near You",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2723))),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _popularWorkspaces.length,
                itemBuilder: (context, index) =>
                    _workspaceCard(_popularWorkspaces[index]),
              ),
            ),
            const SizedBox(height: 20),

            // Available Now
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Available Now",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2723))),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkspacesScreen(
                          userId: widget.userId, userName: widget.userName),
                    ),
                  ),
                  child: const Text("See all >",
                      style: TextStyle(color: Color(0xFF6D4C41))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableWorkspaces.length,
              itemBuilder: (context, index) =>
                  _availableCard(_availableWorkspaces[index]),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Search Results for \"$searchQuery\"",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723)),
              ),
            ),
            const SizedBox(height: 16),
            _filteredWorkspaces.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.search_off,
                      size: 64, color: Color(0xFF8D6E63)),
                  const SizedBox(height: 16),
                  const Text("No workspaces found",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, color: Color(0xFF8D6E63))),
                  const SizedBox(height: 8),
                  const Text("Try \"Hot Desk\" or \"Meeting Room\"",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF8D6E63))),
                ],
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredWorkspaces.length,
              itemBuilder: (context, index) =>
                  _availableCard(_filteredWorkspaces[index]),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _category(IconData icon, String label, String filterType) {
    return GestureDetector(
      onTap: () => _goToCategory(filterType),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF6D4C41),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF3E2723),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // One card method for both Featured and Popular
  Widget _workspaceCard(Map<String, dynamic> item) {
    String name = item['name'] ?? 'Workspace';
    double rate = (item['rate'] ?? 0).toDouble();
    double rating = _workspaceRatings[item['resource_id']] ?? 0.0;
    bool isAvailable = item['availability_status'] == 'Available';

    return GestureDetector(
      onTap: () => _navigateToDetails(item),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD7CCC8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                WorkspaceHelpers.getImage(name),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  color: const Color(0xFFE8D5D0),
                  child: const Icon(Icons.meeting_room_rounded,
                      size: 40, color: Color(0xFF8D6E63)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (rating > 0)
                        RatingStars(rating: rating, size: 12)
                      else
                        const Text(
                          "No reviews yet",
                          style: TextStyle(fontSize: 9, color: Color(0xFF8D6E63)),
                        ),
                      if (isAvailable)
                        Text(
                          "Available",
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF3E2723)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 10, color: Color(0xFF8D6E63)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          WorkspaceHelpers.getLocation(name),
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF8D6E63)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("\$${rate.toStringAsFixed(0)}/hour",
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: Color(0xFF6D4C41))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _availableCard(Map<String, dynamic> item) {
    String name = item['name'] ?? 'Workspace';
    double rate = (item['rate'] ?? 0).toDouble();
    bool isAvailable = item['availability_status'] == 'Available';

    return GestureDetector(
      onTap: () => _navigateToDetails(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD7CCC8)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                WorkspaceHelpers.getImage(name),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  color: const Color(0xFFE8D5D0),
                  child: const Icon(Icons.meeting_room,
                      size: 50, color: Color(0xFF8D6E63)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF3E2723))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Color(0xFF8D6E63)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          WorkspaceHelpers.getLocation(name),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF8D6E63)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (isAvailable)
                        Text("Available",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text("\$${rate.toStringAsFixed(0)}/hour",
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF6D4C41))),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D4C41),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _navigateToDetails(item),
                        child: const Text("Book Now",
                            style: TextStyle(
                                fontSize: 13, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}