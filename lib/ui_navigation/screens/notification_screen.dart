import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, dynamic>> _notifications = const [
    {
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF4CAF50),
      'title': 'Booking Confirmed',
      'message': 'Your Hot Desk booking has been confirmed successfully.',
      'time': '2 mins ago',
      'isRead': false,
    },
    {
      'icon': Icons.payment_rounded,
      'color': Color(0xFF6D4C41),
      'title': 'Payment Received',
      'message': 'Your payment of \$15 has been received successfully.',
      'time': '1 hour ago',
      'isRead': false,
    },
    {
      'icon': Icons.card_membership_rounded,
      'color': Color(0xFF5D4037),
      'title': 'Membership Active',
      'message': 'Your Standard membership plan is now active.',
      'time': '2 hours ago',
      'isRead': true,
    },
    {
      'icon': Icons.meeting_room_rounded,
      'color': Color(0xFF8D6E63),
      'title': 'New Workspace Available',
      'message': 'A new Conference Hall is now available for booking.',
      'time': 'Yesterday',
      'isRead': true,
    },
    {
      'icon': Icons.star_rounded,
      'color': Colors.amber,
      'title': 'Rate Your Experience',
      'message': 'How was your recent booking at Meeting Room 1?',
      'time': 'Yesterday',
      'isRead': true,
    },
    {
      'icon': Icons.cancel_rounded,
      'color': Colors.red,
      'title': 'Booking Cancelled',
      'message': 'Your Dedicated Room booking has been cancelled.',
      'time': '2 days ago',
      'isRead': true,
    },
    {
      'icon': Icons.local_offer_rounded,
      'color': Color(0xFF6D4C41),
      'title': 'Special Offer',
      'message': 'Get 20% off on your next Premium membership plan!',
      'time': '3 days ago',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications
        .where((n) => n['isRead'] == false)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      body: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF5D4037),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$unreadCount unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    "Notifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    "Stay updated with your bookings",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // ── Notifications List ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final bool isRead = notification['isRead'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRead
                        ? Colors.white
                        : const Color(0xFF6D4C41).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRead
                          ? const Color(0xFFD7CCC8)
                          : const Color(0xFF6D4C41).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (notification['color'] as Color)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          notification['icon'] as IconData,
                          color: notification['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notification['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isRead
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                    color: const Color(0xFF3E2723),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6D4C41),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['message'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8D6E63),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification['time'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFBCAAA4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}