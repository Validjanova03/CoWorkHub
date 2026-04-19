import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    final cleaned = local.replaceAll(RegExp(r'[^a-zA-Z]'), ' ').trim();
    if (cleaned.isEmpty) return email;
    return cleaned
        .split(' ')
        .map((w) => w.isNotEmpty
        ? w[0].toUpperCase() + w.substring(1).toLowerCase()
        : '')
        .join(' ');
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final email =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? '';
    final displayName = email.isNotEmpty ? _nameFromEmail(email) : 'User';
    final initials = _initials(displayName);

    final List<Widget> pages = [
      _HomePage(displayName: displayName, initials: initials),
      _PlaceholderPage(
          icon: Icons.meeting_room_rounded, label: 'Spaces',
          onGo: () => Navigator.pushNamed(context, '/workspaces')),
      _PlaceholderPage(
          icon: Icons.calendar_today_rounded, label: 'Bookings',
          onGo: () => Navigator.pushNamed(context, '/my-bookings')),
      _PlaceholderPage(
          icon: Icons.payment_rounded, label: 'Payments',
          onGo: () => Navigator.pushNamed(context, '/payment')),
      _ProfilePage(displayName: displayName, initials: initials),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111128),
          border: Border(
            top: BorderSide(color: Color(0xFF2E2E55), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF111128),
          selectedItemColor: const Color(0xFF8B7CF6),
          unselectedItemColor: const Color(0xFF555577),
          selectedLabelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined),
              activeIcon: Icon(Icons.meeting_room_rounded),
              label: 'Spaces',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment_outlined),
              activeIcon: Icon(Icons.payment_rounded),
              label: 'Payments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ───────────────────────────────────────────────────────────────

class _HomePage extends StatelessWidget {
  final String displayName;
  final String initials;

  const _HomePage({required this.displayName, required this.initials});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A0533), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Good morning! ',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                  Icon(Icons.wb_sunny_rounded,
                                      color: Colors.amber.shade400, size: 14),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white),
                                onPressed: () {},
                              ),
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                Colors.white.withOpacity(0.25),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium_rounded,
                                color: Colors.white70, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Pro Member  •  Active',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: const [],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Row(
                  children: [
                    _StatCard(
                      value: '12',
                      label: 'Total\nBookings',
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      value: '3',
                      label: 'Active\nSpaces',
                      icon: Icons.meeting_room_rounded,
                      color: const Color(0xFF06B6D4),
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      value: '5★',
                      label: 'Your\nRating',
                      icon: Icons.star_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE0E0FF)),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                  children: [
                    _ActionCard(icon: Icons.meeting_room_rounded,
                        label: 'Workspaces',
                        color: const Color(0xFF4F46E5),
                        route: '/workspaces'),
                    _ActionCard(icon: Icons.calendar_today_rounded,
                        label: 'My Bookings',
                        color: const Color(0xFF06B6D4),
                        route: '/my-bookings'),
                    _ActionCard(icon: Icons.card_membership_rounded,
                        label: 'Membership',
                        color: const Color(0xFF8B5CF6),
                        route: '/membership'),
                    _ActionCard(icon: Icons.payment_rounded,
                        label: 'Payments',
                        color: const Color(0xFF10B981),
                        route: '/payment'),
                    _ActionCard(icon: Icons.history_rounded,
                        label: 'History',
                        color: const Color(0xFFF59E0B),
                        route: '/payment-history'),
                    _ActionCard(icon: Icons.feedback_rounded,
                        label: 'Feedback',
                        color: const Color(0xFFEF4444),
                        route: '/feedback'),
                  ],
                ),
                const SizedBox(height: 24),

                // Featured Spaces
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Spaces',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE0E0FF)),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/workspaces'),
                      child: const Text('See all',
                          style: TextStyle(
                              color: Color(0xFF8B7CF6), fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _SpaceCard(
                  name: 'Executive Suite A',
                  location: 'Floor 3, Block B',
                  capacity: '8 people',
                  price: '\$45/hr',
                  tag: 'Popular',
                  tagColor: const Color(0xFF4F46E5),
                  onTap: () => Navigator.pushNamed(context, '/details'),
                ),
                const SizedBox(height: 10),
                _SpaceCard(
                  name: 'Creative Studio',
                  location: 'Floor 1, Block A',
                  capacity: '4 people',
                  price: '\$25/hr',
                  tag: 'New',
                  tagColor: const Color(0xFF10B981),
                  onTap: () => Navigator.pushNamed(context, '/details'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Placeholder Tab ─────────────────────────────────────────────────────────

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onGo;

  const _PlaceholderPage(
      {required this.icon, required this.label, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2E2E55)),
            ),
            child: Icon(icon, color: const Color(0xFF8B7CF6), size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE0E0FF)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap below to open this section',
            style: TextStyle(fontSize: 13, color: Color(0xFF555577)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onGo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Go to $label'),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Tab ─────────────────────────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  final String displayName;
  final String initials;

  const _ProfilePage(
      {required this.displayName, required this.initials});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFF4F46E5),
              child: Text(
                initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE0E0FF)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pro Member',
              style: TextStyle(fontSize: 13, color: Color(0xFF8B7CF6)),
            ),
            const SizedBox(height: 24),
            _ProfileItem(
                icon: Icons.person_outline_rounded, label: 'Edit Profile'),
            _ProfileItem(
                icon: Icons.card_membership_rounded, label: 'Membership',
                onTap: () => Navigator.pushNamed(context, '/membership')),
            _ProfileItem(
                icon: Icons.history_rounded, label: 'Payment History',
                onTap: () =>
                    Navigator.pushNamed(context, '/payment-history')),
            _ProfileItem(
                icon: Icons.feedback_rounded, label: 'Feedback',
                onTap: () => Navigator.pushNamed(context, '/feedback')),
            _ProfileItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: Colors.red.shade400,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/')),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ProfileItem(
      {required this.icon,
        required this.label,
        this.color,
        this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E2E55)),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: color ?? const Color(0xFF8B7CF6), size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color ?? const Color(0xFFE0E0FF)),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: const Color(0xFF555577)),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.value,
        required this.label,
        required this.icon,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E2E55)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF555577))),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _ActionCard(
      {required this.icon,
        required this.label,
        required this.color,
        required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E2E55)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9090BB))),
          ],
        ),
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  final String name;
  final String location;
  final String capacity;
  final String price;
  final String tag;
  final Color tagColor;
  final VoidCallback onTap;

  const _SpaceCard(
      {required this.name,
        required this.location,
        required this.capacity,
        required this.price,
        required this.tag,
        required this.tagColor,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E2E55)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.meeting_room_rounded,
                  color: tagColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFFE0E0FF))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(tag,
                            style: TextStyle(
                                fontSize: 9,
                                color: tagColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(location,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF555577))),
                  Text(capacity,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF555577))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: tagColor)),
                const SizedBox(height: 6),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: Color(0xFF555577)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}