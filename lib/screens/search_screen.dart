import 'package:flutter/material.dart';
import '../widgets/common/search_bar.dart';
import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../core/colors.dart';
import 'details_screen.dart';
import 'cinema_details_screen.dart';

enum SearchMode { movies, cinemas }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  SearchMode _mode = SearchMode.movies;

  // simple mock cinemas list used for search results
  final List<Map<String, dynamic>> _cinemas = [
    {
      'name': 'Cineplex Downtown',
      'address': '123 Movie Lane, Cityville',
      'distance': '1.5 miles away',
      'amenities': ['IMAX', 'Dolby Atmos', 'Accessible']
    },
    {
      'name': 'Grand Cinema Hall',
      'address': '456 Film Avenue, Movietown',
      'distance': '3.2 miles away',
      'amenities': ['4DX', 'Recliners']
    },
    {
      'name': 'Galaxy Theaters',
      'address': '789 Starway, Metropolis',
      'distance': '5.1 miles away',
      'amenities': ['IMAX', 'Accessible']
    },
  ];

  List<Movie> _movieResults(String q) {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return mockMovies.where((m) => m.title.toLowerCase().contains(lower)).toList();
  }

  List<Map<String, dynamic>> _cinemaResults(String q) {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return _cinemas.where((c) => c['name'].toLowerCase().contains(lower) || c['address'].toLowerCase().contains(lower)).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text;
    final movieResults = _movieResults(query);
    final cinemaResults = _cinemaResults(query);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')), // changed title to 'Search' for clarity
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchBar(
              placeholder: 'Search movies or cinemas...',
              controller: _controller,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Mode toggle
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Movies'),
                  selected: _mode == SearchMode.movies,
                  onSelected: (_) => setState(() => _mode = SearchMode.movies),
                  selectedColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Cinemas'),
                  selected: _mode == SearchMode.cinemas,
                  onSelected: (_) => setState(() => _mode = SearchMode.cinemas),
                  selectedColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: query.trim().isEmpty
                  ? Center(
                      child: Text(
                        'Search for a movie or cinema',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    )
                  : _mode == SearchMode.movies
                      ? ListView.builder(
                          itemCount: movieResults.length,
                          itemBuilder: (context, index) {
                            final m = movieResults[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              leading: SizedBox(
                                width: 56,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: m.bannerUrl.isNotEmpty ? Image.asset(m.bannerUrl, fit: BoxFit.cover) : Icon(Icons.movie, color: AppColors.jumbo),
                                ),
                              ),
                              title: Text(m.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              subtitle: Text(m.duration, style: TextStyle(color: AppColors.jumbo)),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: m))),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: cinemaResults.length,
                          itemBuilder: (context, index) {
                            final c = cinemaResults[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CinemaDetailsScreen())),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: const Color(0xFF141A20), borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(c['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                                        const Icon(Icons.star_border, color: Colors.white),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                  Text(c['address'], style: TextStyle(color: AppColors.jumbo)),
                  const SizedBox(height: 6),
                  Text(c['distance'], style: TextStyle(color: AppColors.dodgerBlue)),
                                    const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: (c['amenities'] as List<String>)
                      .map((a) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF0F1720), borderRadius: BorderRadius.circular(20)),
                          child: Text(a, style: TextStyle(color: AppColors.dodgerBlue)),
                        ))
                      .toList()),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
