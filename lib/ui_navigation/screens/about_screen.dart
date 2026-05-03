import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header with background image ──
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Background image
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/workspace.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                // Dark overlay
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                // Back button
                Positioned(
                  top: 50,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Title
                const Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "About Us",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Logo circle
                Positioned(
                  bottom: -40,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D4037),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.corporate_fare_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 56),

            // ── Title Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD7CCC8)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "CoworkHub",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Your Space. Your Productivity.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6D4C41),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "CoworkHub is a modern workspace booking platform that helps professionals and teams find and book the perfect spaces to work, meet and grow.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8D6E63),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Mission & Vision ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _missionVisionCard(
                      icon: Icons.track_changes_rounded,
                      title: "Our Mission",
                      description:
                      "To make quality workspaces accessible to everyone and empower people to do their best work in inspiring environments.",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _missionVisionCard(
                      icon: Icons.remove_red_eye_outlined,
                      title: "Our Vision",
                      description:
                      "To be the leading platform for workspace solutions, connecting people with spaces that fuel productivity and success.",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Why Choose CoworkHub ──
            const Text(
              "Why Choose CoworkHub?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _whyCard(
                      icon: Icons.domain_rounded,
                      title: "Premium Spaces",
                      description:
                      "Carefully selected workspaces that meet high standards of quality and comfort.",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _whyCard(
                      icon: Icons.calendar_today_rounded,
                      title: "Easy Booking",
                      description:
                      "Quick and simple booking process in just a few taps.",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _whyCard(
                      icon: Icons.verified_user_rounded,
                      title: "Secure & Reliable",
                      description:
                      "Your bookings and payments are safe and protected with us.",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _whyCard(
                      icon: Icons.headset_mic_rounded,
                      title: "24/7 Support",
                      description:
                      "We're here to help you anytime, anywhere.",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Our Values ──
            const Text(
              "Our Values",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _valueItem(Icons.groups_rounded, "Community",
                      "Building a community of professionals and innovators."),
                  _valueItem(Icons.star_outline_rounded, "Quality",
                      "We never compromise on the quality of our spaces."),
                  _valueItem(Icons.lightbulb_outline_rounded, "Innovation",
                      "Continuously improving to provide the best experience."),
                  _valueItem(Icons.favorite_outline_rounded, "Integrity",
                      "Transparent, honest and customer focused."),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Footer ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE0D4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Let's build better workdays, together.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Thank you for choosing CoworkHub.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Social media icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialIcon(Icons.facebook_rounded),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.camera_alt_rounded),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.link_rounded),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.alternate_email_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _missionVisionCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6D4C41), size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8D6E63),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _whyCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6D4C41), size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8D6E63),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueItem(IconData icon, String title, String description) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5EDE8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6D4C41), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8D6E63),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFF5D4037),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}