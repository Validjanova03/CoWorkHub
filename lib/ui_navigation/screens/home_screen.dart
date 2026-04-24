import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/ui_navigation/screens/workspaces_screen.dart';
import 'package:coworkhub/ui_navigation/screens/workspace_details_screen.dart';
import 'package:coworkhub/payment_feedback_logic/widgets/rating_stars.dart';
import 'package:coworkhub/booking_membership_logic/screens/my_bookings_screen.dart';
import 'package:coworkhub/payment_feedback_logic/screens/payment_history_screen.dart';

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
      if (hour < 12) {
        _greeting = "Good Morning";
      } else if (hour < 18) {
        _greeting = "Good Afternoon";
      } else {
        _greeting = "Good Evening";
      }
    });
  }

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

  String _getLocationForFeatured(String roomName) {
    Map<String, String> locations = {
      'Hot Desk 1': 'Levent, Istanbul',
      'Hot Desk 5': 'Maslak, Istanbul',
      'Dedicated Room 2': 'Beşiktaş, Istanbul',
      'Meeting Room 1': 'Şişli, Istanbul',
    };
    return locations[roomName] ?? 'Istanbul';
  }

  String _getNearbyLocation(String roomName) {
    Map<String, String> nearbyLocations = {
      'Hot Desk 2': 'Moda, 1.2km away',
      'Dedicated Room 1': 'Feneryolu, 800m away',
      'Dedicated Room 4': 'Bostancı, 3.5km away',
      'Meeting Room 3': 'Acıbadem, 2.1km away',
    };
    return nearbyLocations[roomName] ?? 'Near you';
  }

  String _getAvailableLocation(String roomName) {
    Map<String, String> locations = {
      'Hot Desk 3': 'Kadiköy, Istanbul',
      'Dedicated Room 3': 'Levent, Istanbul',
      'Meeting Room 2': 'Beşiktaş, Istanbul',
    };
    return locations[roomName] ?? 'Istanbul';
  }

  Future<void> _loadWorkspaces() async {
    setState(() => _isLoading = true);
    try {
      DBHelper dbHelper = DBHelper();
      _allWorkspaces = await dbHelper.getWorkspaces();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading workspaces: $e');
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
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _featuredWorkspaces {
    List<int> featuredIndices = [0, 4, 6, 9];
    return featuredIndices.map((i) => _allWorkspaces[i]).toList();
  }

  List<Map<String, dynamic>> get _popularWorkspaces {
    List<int> popularIndices = [1, 5, 8, 11];
    return popularIndices.map((i) => _allWorkspaces[i]).toList();
  }

  List<Map<String, dynamic>> get _availableWorkspaces {
    return _allWorkspaces
        .where((w) => w['availability_status'] == 'Available')
        .take(3)
        .toList();
  }

  // NEW: Filtered workspaces based on search query
  List<Map<String, dynamic>> get _filteredWorkspaces {
    if (searchQuery.isEmpty) return [];
    return _allWorkspaces.where((workspace) {
      final name = workspace['name']?.toLowerCase() ?? '';
      final type = workspace['space_type']?.toLowerCase() ?? '';
      return name.contains(searchQuery) || type.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      WorkspacesScreen(userId: widget.userId),
      MyBookingsScreen(userId: widget.userId),
      PaymentHistoryScreen(userId: widget.userId),
      _buildProfilePage(),
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

  Widget _buildProfilePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF6D4C41),
            child: Text(
              getInitials(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.userName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Member since 2025",
            style: TextStyle(color: Color(0xFF8D6E63)),
          ),
          const SizedBox(height: 24),
          _buildProfileMenuItem(Icons.history_rounded, "Payment History", () {
            setState(() => _currentIndex = 3);
          }),
          _buildProfileMenuItem(Icons.logout_rounded, "Logout", () {
            Navigator.pushReplacementNamed(context, '/');
          }),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6D4C41)),
      title: Text(title, style: const TextStyle(color: Color(0xFF3E2723))),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8D6E63)),
      onTap: onTap,
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
                        Text(
                          _greeting,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _getGreetingIcon(),
                          color: Colors.amber.shade400,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Istanbul, Kadiköy",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Notifications coming soon!")),
                        );
                      },
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
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
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                },
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
                _category(Icons.lock_outline_rounded, "Private", "Private"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Only show regular content if NOT searching
          if (searchQuery.isEmpty) ...[
            // Explore Workspaces Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Explore Workspaces",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Find the best spaces for your productivity",
                    style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Featured Workspaces
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Featured Workspaces",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E2723),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _featuredWorkspaces.length,
                itemBuilder: (context, index) {
                  final item = _featuredWorkspaces[index];
                  return _featuredCard(item);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Popular Near You
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Popular Near You",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E2723),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _popularWorkspaces.length,
                itemBuilder: (context, index) {
                  final item = _popularWorkspaces[index];
                  return _popularCard(item);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Available Now
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Available Now",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkspacesScreen(userId: widget.userId),
                      ),
                    );
                  },
                  child: const Text(
                    "See all >",
                    style: TextStyle(color: Color(0xFF6D4C41)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableWorkspaces.length,
              itemBuilder: (context, index) {
                final item = _availableWorkspaces[index];
                return _availableCard(item);
              },
            ),
          ] else ...[
            // Search Results Section
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Search Results for \"$searchQuery\"",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E2723),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _filteredWorkspaces.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Color(0xFF8D6E63)),
                  const SizedBox(height: 16),
                  const Text(
                    "No workspaces found",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF8D6E63)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Try \"Hot Desk\" or \"Meeting Room\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF8D6E63)),
                  ),
                ],
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredWorkspaces.length,
              itemBuilder: (context, index) {
                return _availableCard(_filteredWorkspaces[index]);
              },
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3E2723),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredCard(Map<String, dynamic> item) {
    String name = item['name'] ?? 'Workspace';
    double rate = (item['rate'] ?? 0).toDouble();
    bool isAvailable = item['availability_status'] == 'Available';
    double rating = 4.5;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkspaceDetailsScreen(
              workspace: item,
              userId: widget.userId,
            ),
          ),
        );
      },
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
                _getImageForWorkspace(item['name']),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: const Color(0xFFE8D5D0),
                    child: const Icon(Icons.meeting_room_rounded, size: 40, color: Color(0xFF8D6E63)),
                  );
                },
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
                      RatingStars(rating: rating, size: 12),
                      if (isAvailable)
                        Text(
                          "Available",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF3E2723),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF8D6E63)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          _getLocationForFeatured(name),
                          style: const TextStyle(fontSize: 9, color: Color(0xFF8D6E63)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${rate.toStringAsFixed(0)}/hour",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popularCard(Map<String, dynamic> item) {
    String name = item['name'] ?? 'Workspace';
    double rate = (item['rate'] ?? 0).toDouble();
    bool isAvailable = item['availability_status'] == 'Available';
    double rating = 4.5;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkspaceDetailsScreen(
              workspace: item,
              userId: widget.userId,
            ),
          ),
        );
      },
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
                _getImageForWorkspace(item['name']),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: const Color(0xFFE8D5D0),
                    child: const Icon(Icons.meeting_room_rounded, size: 40, color: Color(0xFF8D6E63)),
                  );
                },
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
                      RatingStars(rating: rating, size: 12),
                      if (isAvailable)
                        Text(
                          "Available",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF3E2723),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF8D6E63)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          _getNearbyLocation(name),
                          style: const TextStyle(fontSize: 9, color: Color(0xFF8D6E63)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${rate.toStringAsFixed(0)}/hour",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkspaceDetailsScreen(
              workspace: item,
              userId: widget.userId,
            ),
          ),
        );
      },
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
                _getImageForWorkspace(item['name']),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: const Color(0xFFE8D5D0),
                    child: const Icon(Icons.meeting_room, size: 50, color: Color(0xFF8D6E63)),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8D6E63)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getAvailableLocation(name),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF8D6E63)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (isAvailable)
                        Text(
                          "Available",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        "\$${rate.toStringAsFixed(0)}/hour",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF6D4C41),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D4C41),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkspaceDetailsScreen(
                                workspace: item,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Book Now",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
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