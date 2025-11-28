import 'package:cineway/core/colors.dart';
import 'package:cineway/data/mock_movies.dart';
import 'package:cineway/models/movie.dart';
import 'package:cineway/screens/reviews_screen.dart';
import 'package:cineway/screens/showtimes_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/common/cast_item.dart';
import '../widgets/common/chip_ui.dart';
import '../widgets/common/info_box.dart';
import '../widgets/common/tab_item.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie? movie;

  const MovieDetailsScreen({super.key, this.movie});

  @override
  Widget build(BuildContext context) {
  final Movie m = movie ?? mockMovies[0];

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
                m.bannerUrl,
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
                    m.title,
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
                    children: m.categories
                        .map((cat) => ChipUI(cat))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Info Box Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoBox(icon: Icons.calendar_month, label: m.releaseYear.toString()),
                      InfoBox(icon: Icons.timer, label: m.duration),
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
                                builder: (_) => ReviewsScreen(movie: m),
                              ),
                            );
                          },
                        ),

                        TabItem(label: "Showtimes", active: false, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ShowtimesScreen(movieTitle: m.title)));
                        }),
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
                    m.description, // ← dynamic
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
                      children: m.cast
                          .map((actor) => CastItem(actor.name, actor.imageUrl))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Buy Tickets Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cerulean,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ShowtimesScreen(movieTitle: m.title)));
                      },
                      child: const Text(
                        "Buy Tickets",
                        style: TextStyle(
                          color: Colors.white,
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
