import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../viewmodel/search_viewmodel.dart';
import '../core/colors.dart';
import '../models/movie.dart';
import '../models/cinema.dart';
import '../models/recent_search.dart';
import '../repository/movie_repository.dart';
import '../repository/cinema_repository.dart';
import 'details_screen.dart';
import 'cinema_details_screen.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MovieRepository _movieRepo = MovieRepository();
  final CinemaRepository _cinemaRepo = CinemaRepository();
  
  String _selectedFilter = 'All'; // All, Movies, Cinemas
  List<RecentSearch> _recentSearches = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _searchResults = [];
  List<Cinema> _cinemaSearchResults = [];
  bool _isLoading = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadTrendingMovies();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final String? searchesJson = prefs.getString('recent_searches');
    if (searchesJson != null) {
      final List decoded = jsonDecode(searchesJson);
      setState(() {
        _recentSearches = decoded.map((e) => RecentSearch.fromJson(e)).toList();
        _recentSearches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _recentSearches = _recentSearches.take(3).toList();
      });
    }
  }

  Future<void> _saveRecentSearch(String query, String type, {String? subtitle}) async {
    final search = RecentSearch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      query: query,
      type: type,
      timestamp: DateTime.now(),
      subtitle: subtitle,
    );
    
    _recentSearches.removeWhere((s) => s.query.toLowerCase() == query.toLowerCase());
    _recentSearches.insert(0, search);
    _recentSearches = _recentSearches.take(3).toList();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_searches', jsonEncode(_recentSearches.map((e) => e.toJson()).toList()));
    
    setState(() {});
  }

  Future<void> _clearAllSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() {
      _recentSearches = [];
    });
  }

  Future<void> _removeSearch(String id) async {
    setState(() {
      _recentSearches.removeWhere((s) => s.id == id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_searches', jsonEncode(_recentSearches.map((e) => e.toJson()).toList()));
  }

  Future<void> _loadTrendingMovies() async {
    try {
      final movies = await _movieRepo.getAllMovies();
      setState(() {
        _trendingMovies = movies.take(10).toList();
      });
    } catch (e) {
      debugPrint('Error loading trending movies: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _showResults = false;
        _searchResults = [];
        _cinemaSearchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showResults = true;
    });

    try {
      if (_selectedFilter == 'All' || _selectedFilter == 'Movies') {
        final movies = await _movieRepo.searchMovies(query);
        setState(() {
          _searchResults = movies;
        });
      }
      
      if (_selectedFilter == 'All' || _selectedFilter == 'Cinemas') {
        final cinemas = await _cinemaRepo.searchCinemas(query);
        setState(() {
          _cinemaSearchResults = cinemas;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onRecentSearchTap(RecentSearch search) {
    _searchController.text = search.query;
    _performSearch(search.query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Search',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.transparent),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search movies, cinemas...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    _performSearch(value);
                  },
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _saveRecentSearch(value, 'movie');
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 12),
                  _buildFilterChip('Movies'),
                  const SizedBox(width: 12),
                  _buildFilterChip('Cinemas'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _showResults && _searchController.text.isNotEmpty
                  ? _buildSearchResults()
                  : _buildInitialContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
        if (_searchController.text.isNotEmpty) {
          _performSearch(_searchController.text);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.dodgerBlue : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.dodgerBlue : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextButton(
                    onPressed: _clearAllSearches,
                    child: const Text(
                      'Clear all',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.dodgerBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._recentSearches.map((search) => _buildRecentSearchItem(search)).toList(),
            const SizedBox(height: 32),
          ],

          // Trending Now
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Trending Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.dodgerBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.trending_up, size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _trendingMovies.length,
              itemBuilder: (context, index) {
                final movie = _trendingMovies[index];
                return _buildTrendingMovieCard(movie);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(RecentSearch search) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => _onRecentSearchTap(search),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  search.type == 'cinema' ? Icons.location_on : Icons.schedule,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      search.query,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    if (search.subtitle != null)
                      Text(
                        search.subtitle!,
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeSearch(search.id),
                icon: Icon(Icons.close, color: Colors.white.withOpacity(0.5), size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        _saveRecentSearch(movie.title, 'movie');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1E1E1E),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      movie.bannerUrl,
                      width: 140,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1E1E1E),
                        child: const Icon(Icons.movie, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.dodgerBlue, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          movie.rating,
                          style: const TextStyle(
                            color: AppColors.dodgerBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            Text(
              '${movie.categories.isNotEmpty ? movie.categories.first : "Movie"} • ${movie.duration ?? "2h"}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.dodgerBlue));
    }

    if (_searchResults.isEmpty && _cinemaSearchResults.isEmpty) {
      return const Center(
        child: Text('No results found', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Movie Results
        if (_searchResults.isNotEmpty && (_selectedFilter == 'All' || _selectedFilter == 'Movies')) ...[
          const Text('Movies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          ..._searchResults.map((movie) => _buildMovieResultCard(movie)).toList(),
          const SizedBox(height: 24),
        ],

        // Cinema Results
        if (_cinemaSearchResults.isNotEmpty && (_selectedFilter == 'All' || _selectedFilter == 'Cinemas')) ...[
          const Text('Cinemas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          ..._cinemaSearchResults.map((cinema) => _buildCinemaResultCard(cinema)).toList(),
        ],
      ],
    );
  }

  Widget _buildMovieResultCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        _saveRecentSearch(movie.title, 'movie');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie.bannerUrl,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 80,
                  color: const Color(0xFF2A2A2A),
                  child: const Icon(Icons.movie, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.categories.join(', '),
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.dodgerBlue, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating,
                        style: const TextStyle(fontSize: 12, color: AppColors.dodgerBlue, fontWeight: FontWeight.bold),
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
  }

  Widget _buildCinemaResultCard(Cinema cinema) {
    return GestureDetector(
      onTap: () {
        _saveRecentSearch(cinema.name, 'cinema', subtitle: 'Cinema • ${cinema.city}');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CinemaDetailsScreen(cinemaId: cinema.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_movies, color: AppColors.dodgerBlue, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cinema.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cinema • ${cinema.city}',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
