import 'package:cineway/core/colors.dart';
import 'package:cineway/data/mock_movies.dart';
import 'package:cineway/models/movie.dart';
import 'package:cineway/screens/reviews_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/common/cast_item.dart';
import '../widgets/common/chip_ui.dart';
import '../widgets/common/info_box.dart';
import '../widgets/common/tab_item.dart';

class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Movie movie = mockMovies[0];

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Header Image
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: Colors.black,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                movie.bannerUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Movie Title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Categories
                  Wrap(
                    spacing: 8,
                    children: movie.categories
                        .map((cat) => ChipUI(cat))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Info Box Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoBox(icon: Icons.calendar_month, label: movie.releaseYear.toString()),
                      InfoBox(icon: Icons.timer, label: movie.duration),
                      const InfoBox(icon: Icons.shield, label: "PG-13"),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Tabs Container
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.mirageLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TabItem(label: "About Movie", active: true, onTap: () {}),

                        TabItem(
                          label: "Reviews",
                          active: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewsScreen(movie: movie),
                              ),
                            );
                          },
                        ),

                        TabItem(label: "Showtimes", active: false, onTap: () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Synopsis
                  const Text(
                    "Synopsis",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    movie.description, // ← dynamic
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),

                  const SizedBox(height: 20),

                  // Cast Title
                  const Text(
                    "Cast",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Cast List
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: movie.cast
                          .map((actor) => CastItem(actor.name, actor.imageUrl))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Buy Tickets Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cerulean,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Buy Tickets",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
