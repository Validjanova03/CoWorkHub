import 'package:flutter/material.dart';
import 'package:coworkhub/booking_membership_logic/services/membership_service.dart';
import 'package:coworkhub/ui_navigation/helper/snackbar_helper.dart';

class MembershipPlansScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const MembershipPlansScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  final MembershipService membershipService = MembershipService();
  List<Map<String, dynamic>> plans = [];
  Map<String, dynamic>? activeMembership;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
    loadActiveMembership();
  }

  Future<void> loadPlans() async {
    final data = await membershipService.getPlans();
    setState(() { plans = data; isLoading = false; });
  }

  Future<void> loadActiveMembership() async {
    final memberships = await membershipService.getUserMemberships(widget.userId);
    setState(() {
      activeMembership = memberships.firstWhere(
            (m) => m['status'] == 'Active',
        orElse: () => {},
      );
    });
  }

  Future<void> subscribeToPlan(int planId) async {
    final error = await membershipService.subscribeToPlan(
      userId: widget.userId,
      planId: planId,
    );

    if (!mounted) return;

    if (error != null) {
      SnackbarHelper.showError(context, error);
      return;
    }

    SnackbarHelper.showSuccess(context, 'Membership subscribed successfully!');

    await loadActiveMembership();
    setState(() {});
  }

  IconData _getPlanIcon(String planName) {
    if (planName.toLowerCase().contains('weekly')) return Icons.calendar_view_week_rounded;
    if (planName.toLowerCase().contains('standard')) return Icons.star_rounded;
    if (planName.toLowerCase().contains('premium')) return Icons.workspace_premium_rounded;
    return Icons.card_membership_rounded;
  }

  Color _getPlanColor(String planName) {
    if (planName.toLowerCase().contains('weekly')) return const Color(0xFF8D6E63);
    if (planName.toLowerCase().contains('standard')) return const Color(0xFF6D4C41);
    if (planName.toLowerCase().contains('premium')) return const Color(0xFF3E2723);
    return const Color(0xFF6D4C41);
  }

  void _showMembershipPaymentSheet(Map<String, dynamic> plan) {
    final cardController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();
    String detectedCard = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7CCC8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Card Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 20),

                // Card Number
                const Text("Card Number",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723))),
                const SizedBox(height: 8),
                TextField(
                  controller: cardController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setSheetState(() {
                      if (value.startsWith('4')) {
                        detectedCard = 'visa';
                      } else if (value.startsWith('5')) {
                        detectedCard = 'mastercard';
                      } else {
                        detectedCard = '';
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "1234 5678 9012 3456",
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.credit_card_rounded,
                        color: Color(0xFF6D4C41)),
                    suffixIcon: detectedCard.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/$detectedCard.png',
                        height: 30,
                      ),
                    )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFFAF7F4),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xFFD7CCC8))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xFFD7CCC8))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xFF6D4C41))),
                  ),
                ),
                const SizedBox(height: 16),

                // Cardholder Name
                const Text("Cardholder Name",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723))),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "John Doe",
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: Color(0xFF6D4C41)),
                    filled: true,
                    fillColor: const Color(0xFFFAF7F4),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xFFD7CCC8))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xFFD7CCC8))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xFF6D4C41))),
                  ),
                ),
                const SizedBox(height: 16),

                // Expiry and CVV
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Expiry Date",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3E2723))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: expiryController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "MM/YY",
                              hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF)),
                              filled: true,
                              fillColor: const Color(0xFFFAF7F4),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD7CCC8))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD7CCC8))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF6D4C41))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("CVV",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3E2723))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "123",
                              hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF)),
                              counterText: "",
                              filled: true,
                              fillColor: const Color(0xFFFAF7F4),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD7CCC8))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD7CCC8))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF6D4C41))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Total
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EDE8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      Text(
                        "\$${(plan['price'] ?? 0).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pay Now Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      subscribeToPlan(plan['plan_id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D4037),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      "Pay Now",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Membership Plans",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    "Choose the plan that fits your needs",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6D4C41),
              ),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Active Membership Card ──
                  if (activeMembership != null &&
                      activeMembership!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6D4C41),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Colors.amber, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Active Membership",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Expires: ${activeMembership!['end_date']?.toString().split(' ')[0] ?? 'N/A'}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Plans Title ──
                  const Text(
                    "Available Plans",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "All plans include access to all workspaces",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Plan Cards ──
                  ...plans.map((plan) {
                    String planName = plan['plan_name'] ?? '';
                    double price = (plan['price'] ?? 0).toDouble();
                    String periodicity = plan['payment_periodicity'] ?? '';
                    int discount = plan['discount_applied'] ?? 0;
                    bool isPopular = planName.toLowerCase().contains('standard');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPopular
                              ? const Color(0xFF6D4C41)
                              : const Color(0xFFD7CCC8),
                          width: isPopular ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Plan Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getPlanColor(planName),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(_getPlanIcon(planName),
                                        color: Colors.white, size: 24),
                                    const SizedBox(width: 10),
                                    Text(
                                      planName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isPopular)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Popular",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3E2723),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Plan Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${price.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3E2723),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 6),
                                      child: Text(
                                        "/ $periodicity",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8D6E63),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.local_offer_rounded,
                                        size: 16,
                                        color: Color(0xFF6D4C41)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$discount% discount applied",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6D4C41),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Divider(color: Color(0xFFD7CCC8)),
                                const SizedBox(height: 8),

                                // Features
                                _planFeature("Access to all workspaces"),
                                _planFeature("Free cancellation"),
                                _planFeature("Priority booking"),
                                if (!planName.toLowerCase().contains('weekly'))
                                  _planFeature("Dedicated support"),
                                if (planName.toLowerCase().contains('premium'))
                                  _planFeature("Guest passes included"),

                                const SizedBox(height: 16),

                                // Subscribe Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showMembershipPaymentSheet(plan),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      _getPlanColor(planName),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Subscribe Now",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 16, color: Color(0xFF6D4C41)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }
}