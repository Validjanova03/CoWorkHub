import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      body: Column(
        children: [
          // ── AppBar ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 50, 20, 16),
            color: const Color(0xFF5D4037),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "Help & Support",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── How can we help you ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EDE8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "How can we help you?",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "We're here to help and ensure you have the best experience with CoworkHub.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8D6E63),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.search,
                                        color: Color(0xFF8D6E63), size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "Search help articles...",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF8D6E63),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.headset_mic_rounded,
                          size: 80,
                          color: Color(0xFF6D4C41),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Quick Help ──
                  const Text(
                    "Quick Help",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _quickHelpCard(
                          Icons.help_outline_rounded,
                          "FAQs",
                          "Find answers to common questions",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _quickHelpCard(
                          Icons.calendar_today_rounded,
                          "Booking Help",
                          "Learn how to book and manage bookings",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _quickHelpCard(
                          Icons.payment_rounded,
                          "Payments",
                          "Get help with payments and invoices",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _quickHelpCard(
                          Icons.person_outline_rounded,
                          "Account",
                          "Manage your account and settings",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Popular Articles ──
                  const Text(
                    "Popular Articles",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD7CCC8)),
                    ),
                    child: Column(
                      children: [
                        _articleItem(
                          "How do I book a workspace?",
                          "Go to the Spaces tab, select your preferred workspace, choose your time slot and tap Book Now.",
                        ),
                        _divider(),
                        _articleItem(
                          "How can I cancel or reschedule a booking?",
                          "Go to the Bookings tab, find your booking and tap Cancel Booking.",
                        ),
                        _divider(),
                        _articleItem(
                          "What payment methods do you accept?",
                          "We accept Credit/Debit Card, PayPal, Apple Pay and Google Pay.",
                        ),
                        _divider(),
                        _articleItem(
                          "How do I download my invoice?",
                          "Go to the Payments tab, find your payment and tap to view the invoice details.",
                        ),
                        _divider(),
                        _articleItem(
                          "How can I update my profile information?",
                          "Go to Profile tab → Personal Information to update your details.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),


                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EDE8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDE0D4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.headset_mic_rounded,
                            color: Color(0xFF6D4C41),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Still need help?",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Our support team is ready to assist you. We typically reply within a few hours.",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8D6E63),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD7CCC8),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text("Contact Information",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF3E2723))),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(child: _contactCard(Icons.mail_outline_rounded, "Email Us", "support@coworkhub.com", "We'll reply within 24 hours")),
                                        const SizedBox(width: 10),
                                        Expanded(child: _contactCard(Icons.phone_outlined, "Call Us", "+90 212 123 4567", "Mon - Fri, 9AM - 6PM")),
                                        const SizedBox(width: 10),
                                        Expanded(child: _contactCard(Icons.chat_bubble_outline_rounded, "Live Chat", "Chat with our team", "Available in app")),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.mail_outline_rounded,
                              size: 16),
                          label: const Text(
                            "Contact Us",
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D4037),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickHelpCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6D4C41), size: 28),
          const SizedBox(height: 6),
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
              fontSize: 9,
              color: Color(0xFF8D6E63),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ New method
  Widget _articleItem(String question, String answer) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      iconColor: const Color(0xFF6D4C41),
      collapsedIconColor: const Color(0xFF8D6E63),
      leading: const Icon(Icons.article_outlined,
          color: Color(0xFF8D6E63), size: 20),
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3E2723),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8D6E63),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() => const Divider(
      height: 1, color: Color(0xFFD7CCC8), indent: 16, endIndent: 16);

  Widget _contactCard(
      IconData icon, String title, String subtitle, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6D4C41), size: 26),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6D4C41),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF8D6E63),
            ),
          ),
        ],
      ),
    );
  }
}