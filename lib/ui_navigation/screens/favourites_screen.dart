import 'package:flutter/material.dart';
import 'package:coworkhub/database/db_helper.dart';
import 'package:coworkhub/payment_feedback_logic/services/feedback_service.dart';
import 'package:coworkhub/payment_feedback_logic/widgets/rating_stars.dart';
import 'package:coworkhub/services/workspace_service.dart';
import 'package:coworkhub/ui_navigation/helper/workspace_helpers.dart';
import 'package:coworkhub/ui_navigation/screens/workspace_details_screen.dart';

class FavouritesScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const FavouritesScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<FavouritesScreen> createState() =>
      _FavouritesScreenState();
}

class _FavouritesScreenState
    extends State<FavouritesScreen> {

  final DBHelper dbHelper = DBHelper();
  final WorkspaceService workspaceService =
  WorkspaceService();
  final FeedbackService feedbackService =
  FeedbackService();

  List<Map<String, dynamic>> favouriteWorkspaces = [];
  List<Map<String, dynamic>> filteredWorkspaces = [];

  Map<int, double> workspaceRatings = {};

  bool isLoading = true;

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadFavourites();
  }

  Future<void> loadFavourites() async {

    setState(() => isLoading = true);

    final favourites =
    await dbHelper.getFavorites(widget.userId);

    Map<int, double> ratings = {};

    for (var workspace in favourites) {

      int resourceId =
      workspace['resource_id'];

      ratings[resourceId] =
      await feedbackService
          .getAverageRating(resourceId);
    }

    setState(() {

      favouriteWorkspaces = favourites;

      filteredWorkspaces = favourites;

      workspaceRatings = ratings;

      isLoading = false;
    });
  }

  void searchWorkspaces(String value) {

    setState(() {

      searchQuery = value;

      filteredWorkspaces =
          favouriteWorkspaces.where((workspace) {

            final name = workspace['name']
                .toString()
                .toLowerCase();

            return name.contains(
                value.toLowerCase());

          }).toList();
    });
  }

  Future<void> removeFavourite(
      int resourceId) async {

    await dbHelper.removeFavorite(
        widget.userId,
        resourceId);

    await loadFavourites();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFFAF7F4),

      body: Column(

        children: [

          // HEADER
          Container(

            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(
                16, 55, 20, 22),

            decoration: const BoxDecoration(

              color: Color(0xFF5D4037),

              borderRadius: BorderRadius.only(

                bottomLeft: Radius.circular(26),

                bottomRight: Radius.circular(26),
              ),
            ),

            child: Column(

              children: [

                Row(

                  children: [

                    IconButton(

                      onPressed: () =>
                          Navigator.pop(context),

                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                    const Expanded(

                      child: Text(

                        "Favourites",

                        textAlign: TextAlign.center,

                        style: TextStyle(

                          color: Colors.white,

                          fontSize: 21,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 10),

                Container(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                    BorderRadius.circular(14),
                  ),

                  child: TextField(

                    onChanged: searchWorkspaces,

                    decoration: const InputDecoration(

                      border: InputBorder.none,

                      icon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF8D6E63),
                      ),

                      hintText:
                      "Search favourite spaces...",

                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
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

                : filteredWorkspaces.isEmpty

                ? _emptyState()

                : ListView.builder(

              padding:
              const EdgeInsets.all(16),

              itemCount:
              filteredWorkspaces.length,

              itemBuilder:
                  (context, index) {

                final workspace =
                filteredWorkspaces[index];

                final rating =
                    workspaceRatings[
                    workspace[
                    'resource_id']] ??
                        0.0;

                return GestureDetector(

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            WorkspaceDetailsScreen(

                              userId:
                              widget.userId,

                              workspace:
                              workspace,

                              userName:
                              widget.userName,
                            ),
                      ),
                    ).then((_) =>
                        loadFavourites());
                  },

                  child: Container(

                    margin:
                    const EdgeInsets.only(
                        bottom: 16),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                          18),

                      border: Border.all(
                        color: const Color(
                            0xFFD7CCC8),
                      ),
                    ),

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        // IMAGE
                        Stack(

                          children: [

                            ClipRRect(

                              borderRadius:
                              const BorderRadius
                                  .vertical(
                                top: Radius.circular(
                                    18),
                              ),

                              child: Image.asset(

                                WorkspaceHelpers
                                    .getImage(
                                    workspace[
                                    'name']),

                                width:
                                double.infinity,

                                height: 180,

                                fit: BoxFit.cover,
                              ),
                            ),

                            Positioned(

                              top: 14,
                              right: 14,

                              child:
                              GestureDetector(

                                onTap: () {

                                  removeFavourite(
                                      workspace[
                                      'resource_id']);
                                },

                                child: Container(

                                  padding:
                                  const EdgeInsets
                                      .all(8),

                                  decoration:
                                  BoxDecoration(

                                    color: Colors
                                        .white
                                        .withValues(
                                        alpha:
                                        0.9),

                                    shape: BoxShape
                                        .circle,
                                  ),

                                  child: const Icon(

                                    Icons
                                        .favorite_rounded,

                                    color: Colors
                                        .pinkAccent,

                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Padding(

                          padding:
                          const EdgeInsets.all(
                              14),

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [

                              Row(

                                children: [

                                  Expanded(

                                    child: Text(

                                      workspace[
                                      'name'],

                                      style:
                                      const TextStyle(

                                        fontSize: 18,

                                        fontWeight:
                                        FontWeight
                                            .bold,

                                        color: Color(
                                            0xFF3E2723),
                                      ),
                                    ),
                                  ),

                                  Container(

                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal:
                                      10,
                                      vertical: 6,
                                    ),

                                    decoration:
                                    BoxDecoration(

                                      color:
                                      const Color(
                                          0xFF6D4C41)
                                          .withValues(
                                          alpha:
                                          0.08),

                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          10),
                                    ),

                                    child: Text(

                                      "\$${workspace['rate']}/${workspace['unit_type']}",

                                      style:
                                      const TextStyle(

                                        fontSize: 12,

                                        fontWeight:
                                        FontWeight
                                            .w700,

                                        color: Color(
                                            0xFF6D4C41),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height: 8),

                              Row(

                                children: [

                                  const Icon(
                                    Icons
                                        .location_on_outlined,
                                    size: 15,
                                    color: Color(
                                        0xFF8D6E63),
                                  ),

                                  const SizedBox(
                                      width: 4),

                                  Expanded(

                                    child: Text(

                                      WorkspaceHelpers
                                          .getLocation(
                                          workspace[
                                          'name']),

                                      style:
                                      const TextStyle(

                                        fontSize: 12,

                                        color: Color(
                                            0xFF8D6E63),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height: 10),

                              Row(

                                children: [

                                  RatingStars(
                                    rating: rating,
                                    size: 16,
                                  ),

                                  const SizedBox(
                                      width: 8),

                                  Text(

                                    rating
                                        .toStringAsFixed(
                                        1),

                                    style:
                                    const TextStyle(

                                      fontSize: 13,

                                      color: Color(
                                          0xFF8D6E63),
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(

                                    workspace[
                                    'availability_status'],

                                    style: TextStyle(

                                      fontSize: 12,

                                      fontWeight:
                                      FontWeight
                                          .w600,

                                      color: workspace[
                                      'availability_status'] ==
                                          'Available'

                                          ? Colors.green
                                          : Colors.red,
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Container(

              width: 90,
              height: 90,

              decoration: BoxDecoration(

                color: const Color(
                    0xFF6D4C41)
                    .withValues(alpha: 0.08),

                shape: BoxShape.circle,
              ),

              child: const Icon(

                Icons.favorite_border_rounded,

                size: 42,

                color: Color(0xFF6D4C41),
              ),
            ),

            const SizedBox(height: 20),

            const Text(

              "No favourites yet",

              style: TextStyle(

                fontSize: 20,

                fontWeight: FontWeight.bold,

                color: Color(0xFF3E2723),
              ),
            ),

            const SizedBox(height: 8),

            const Text(

              "Save your favourite coworking spaces\nand access them anytime.",

              textAlign: TextAlign.center,

              style: TextStyle(

                fontSize: 13,

                color: Color(0xFF8D6E63),

                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}