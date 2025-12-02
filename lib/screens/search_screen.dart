import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/search_viewmodel.dart';
import '../widgets/common/cinema_card_resume.dart';
import '../widgets/common/movie_card_resume.dart';
import '../widgets/common/search_bar.dart';
import '../core/colors.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // SEARCH BAR
            CustomSearchBar(
              placeholder: 'Search movies, cinemas...',
              controller: vm.searchController,
              onChanged: vm.onSearchChanged,
            ),

            const SizedBox(height: 24),

            // LOADING SPINNER
            if (vm.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            // RESULTS LIST
            Expanded(
              child: ListView(
                children: [

                  // MOVIE RESULTS
                  if (vm.movieResults.isNotEmpty) ...[
                    const Text(
                      "Movies",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 12),

                    for (var movie in vm.movieResults)
                      MovieCardResume(
                        movie: movie,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailsScreen(movieId: movie.id),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 20),
                  ],

                  // CINEMA RESULTS
                  if (vm.cinemaResults.isNotEmpty) ...[
                    const Text(
                      "Cinemas",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 12),

                    for (var cinema in vm.cinemaResults)
                      CinemaCardResume(
                        cinema: cinema,
                        onTap: () {
                          // TODO: create CinemaDetailsScreen(cinema.id)
                        },
                      ),
                  ],

                  // NO RESULTS
                  if (vm.movieResults.isEmpty &&
                      vm.cinemaResults.isEmpty &&
                      !vm.isLoading &&
                      vm.searchController.text.trim().isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          "No results found",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
