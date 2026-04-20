import 'package:flutter/material.dart';

class WorkspacesScreen extends StatefulWidget {
  const WorkspacesScreen({super.key});

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Hot Desk',
    'Dedicated Desk',
    'Meeting Room',
    'Conference Hall'
  ];

  final List<Map<String, dynamic>> _workspaces = [ // a mock database to check if the screen is working
    {
      'name': 'Hot Desk A1',
      'type': 'Hot Desk',
      'capacity': 1,
      'price': 45,
      'rating': 4.9,
      'available': true,
      'floor': 'Floor 3',
      'amenities': ['WiFi', 'Projector', 'AC', 'Coffee'],
      'color': const Color(0xFF4F46E5),
      'icon': Icons.business_center_rounded,
    },
    {
      'name': 'Creative Studio', // (you can keep this if not in DB)
      'type': 'Dedicated Desk',
      'capacity': 4,
      'price': 25,
      'rating': 4.7,
      'available': true,
      'floor': 'Floor 1',
      'amenities': ['WiFi', 'Whiteboard', 'AC'],
      'color': const Color(0xFF10B981),
      'icon': Icons.brush_rounded,
    },
    {
      'name': 'Meeting Room M1',
      'type': 'Meeting Room',
      'capacity': 16,
      'price': 80,
      'rating': 4.8,
      'available': false,
      'floor': 'Floor 5',
      'amenities': ['WiFi', 'TV', 'Projector', 'Coffee', 'AC'],
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.groups_rounded,
    },
    {
      'name': 'Hot Desk A2',
      'type': 'Hot Desk',
      'capacity': 30,
      'price': 15,
      'rating': 4.5,
      'available': true,
      'floor': 'Floor 2',
      'amenities': ['WiFi', 'Coffee', 'Locker'],
      'color': const Color(0xFF06B6D4),
      'icon': Icons.laptop_mac_rounded,
    },
    {
      'name': 'Dedicated Desk D1',
      'type': 'Dedicated Desk',
      'capacity': 2,
      'price': 18,
      'rating': 4.6,
      'available': true,
      'floor': 'Floor 2',
      'amenities': ['WiFi', 'AC'],
      'color': const Color(0xFFF59E0B),
      'icon': Icons.headphones_rounded,
    },
    {
      'name': 'Conference Room C1',
      'type': 'Conference Hall',
      'capacity': 50,
      'price': 150,
      'rating': 4.9,
      'available': true,
      'floor': 'Floor 6',
      'amenities': ['WiFi', 'Stage', 'Projector', 'Sound', 'AC'],
      'color': const Color(0xFFEF4444),
      'icon': Icons.speaker_group_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredWorkspaces {
    if (_selectedFilter == 'All') return _workspaces;
    return _workspaces
        .where((ws) => ws['type'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A), // ✅ dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: const Text(
          'Workspaces',
          style: TextStyle(color: Color(0xFFE0E0FF)), // text color
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE0E0FF)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search workspaces...',
                filled: true,
                fillColor: const Color(0xFF1A1A35),

                hintStyle: const TextStyle(color: Color(0xFF555577), fontSize: 14),

                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF555577)),
                suffixIcon: const Icon(Icons.mic_rounded, color: Color(0xFF555577)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF1A1A35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF2E2E55),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFE0E0FF),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_filteredWorkspaces.length} spaces found',
              style:
              const TextStyle(fontSize: 13, color: Color(0xFF555577)),
            ),
          ),
          const SizedBox(height: 8),

          // Workspaces List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: _filteredWorkspaces.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ws = _filteredWorkspaces[index];
                return _WorkspaceCard(workspace: ws);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  final Map<String, dynamic> workspace;

  const _WorkspaceCard({required this.workspace});

  @override
  Widget build(BuildContext context) {
    final bool available = workspace['available'] as bool;
    final Color color = workspace['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A35),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(workspace['icon'] as IconData,
                      color: color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workspace['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: const Color(0xFFE0E0FF)),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12, color: const Color(0xFF555577)),
                          const SizedBox(width: 2),
                          Text(
                            workspace['floor'],
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              workspace['type'],
                              style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${workspace['price']}/hr',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: color),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: available
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        available ? 'Available' : 'Booked',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: available
                              ? Colors.green.shade700
                              : Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amenities
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (workspace['amenities'] as List<String>)
                  .map((amenity) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D1A),
                  border: Border.all(color: const Color(0xFF2E2E55)),
                ),
                child: Text(
                  amenity,
                  style: const TextStyle(
                      fontSize: 11, color: const Color(0xFF555577)),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 14),

            // Footer Row
            Row(
              children: [
                Icon(Icons.group_outlined,
                    size: 14, color: const Color(0xFF555577)),
                const SizedBox(width: 4),
                Text(
                  'Up to ${workspace['capacity']} people',
                  style: TextStyle(
                      fontSize: 12, color: const Color(0xFF555577)),
                ),
                const SizedBox(width: 12),
                Icon(Icons.star_rounded,
                    size: 14, color: Colors.amber.shade600),
                const SizedBox(width: 2),
                Text(
                  '${workspace['rating']}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: available
                        ? () => Navigator.pushNamed(context, '/details')
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}