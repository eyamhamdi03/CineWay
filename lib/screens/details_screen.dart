import 'package:cineway/core/colors.dart';
import 'package:cineway/screens/reviews_screen.dart';
import 'package:cineway/screens/showtimes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/movie/movie_detail_viewmodel.dart';
import '../viewmodel/movie/movie_review_viewmodel.dart';
import '../widgets/common/cast_item.dart';
import '../widgets/common/chip_ui.dart';
import '../widgets/common/info_box.dart';
import '../widgets/common/tab_item.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MovieDetailViewModel>();

    // Trigger load only once
    if (vm.movie == null && !vm.isLoading) {
      Future.microtask(() => vm.loadMovieById(movieId));
    }

    // Loading state
    if (vm.isLoading || vm.movie == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final movie = vm.movie!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
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
              background: Image.network(
                movie.bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(
                  color: Colors.grey,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TITLE
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // GENRES
                  Wrap(
                    spacing: 8,
                    children: movie.categories
                        .map((cat) => ChipUI(cat))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // INFO BOX
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoBox(
                        icon: Icons.calendar_month,
                        label: movie.releaseYear.toString(),
                      ),
                      InfoBox(icon: Icons.timer, label: movie.duration),
                      InfoBox(icon: Icons.shield, label: movie.rating),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // TABS
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.mirageLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TabItem(
                          label: "About Movie",
                          active: true,
                          onTap: () {},
                        ),
                        TabItem(
                          label: "Reviews",
                          active: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider(
                                  create: (_) => ReviewViewModel(movie),
                                  child: ReviewsScreen(movie: movie),
                                ),
                              ),
                            );
                          },
                        ),
                        TabItem(
                          label: "Showtimes",
                          active: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ShowtimesScreen(movieTitle: movie.title),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SYNOPSIS
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
                    movie.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CAST
                  const Text(
                    "Cast",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: movie.cast
                          .map((actor) =>
                          CastItem(actor.name, actor.imageUrl))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BUTTON
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ShowtimesScreen(movieTitle: movie.title),
                          ),
                        );
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
