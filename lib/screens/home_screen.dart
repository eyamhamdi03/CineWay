import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'movies_screen.dart';
import 'notifications_screen.dart';
import '../models/movie.dart';
import '../repository/movie_repository.dart';
import 'package:provider/provider.dart';
import '../viewmodel/session/session_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Action', 'Romance', 'Comedy', 'Horror', 'Sci-Fi'];
  
  final _repo = MovieRepository();
  bool _loading = true;
  String? _error;
  List<Movie> _allMovies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final movies = await _repo.getAllMovies();
      setState(() => _allMovies = movies);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Movie> get _filteredMovies {
    final selectedCategory = _categories[_selectedCategoryIndex];
    
    if (selectedCategory == 'All') {
      return _allMovies;
    }
    
    return _allMovies.where((movie) {
      return movie.categories.any(
        (category) => category.toLowerCase() == selectedCategory.toLowerCase()
      );
    }).toList();
  }

  List<Movie> get _filteredNowInCinemas {
    final today = DateTime.now();
    final selectedCategory = _categories[_selectedCategoryIndex];
    
    return _allMovies.where((m) {
      // Filter by release date
      final d = m.releaseDate;
      if (d != null && d.isAfter(DateTime(today.year, today.month, today.day))) {
        return false;
      }
      
      // Filter by category
      if (selectedCategory == 'All') {
        return true;
      }
      
      return m.categories.any(
        (category) => category.toLowerCase() == selectedCategory.toLowerCase()
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final firstName = (session.user?.fullName?.trim().split(' ').first ?? 
                      session.user?.email?.split('@').first ?? 
                      'Guest');

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back 👋',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hello, $firstName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFFF5F5F5),
                            size: 20,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3F7),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2C2C2C), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Categories
            SizedBox(
              height: 44,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    child: Container(
                      margin: EdgeInsets.only(right: index < _categories.length - 1 ? 12 : 0),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4FC3F7) : const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(22),
                        border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.05)),
                        boxShadow: isSelected
                            ? [BoxShadow(color: const Color(0xFF4FC3F7).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFB0B0B0),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: _loadMovies, child: const Text('Retry')),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Now in cinemas
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Now in cinemas',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const MoviesScreen(
                                              title: 'Now in Cinemas',
                                              nowInCinemasOnly: true,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'See all',
                                        style: TextStyle(
                                          color: Color(0xFF4FC3F7),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                height: 260,
                                child: _filteredNowInCinemas.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No movies available',
                                          style: TextStyle(color: Color(0xFFB0B0B0)),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _filteredNowInCinemas.length > 5 ? 5 : _filteredNowInCinemas.length,
                                    itemBuilder: (context, index) {
                                      final movie = _filteredNowInCinemas[index];
                                      return GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
                                        ),
                                        child: Container(
                                          width: 180,
                                          margin: EdgeInsets.only(right: index < _filteredNowInCinemas.length - 1 ? 20 : 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(16),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.2),
                                                          blurRadius: 20,
                                                          offset: const Offset(0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: movie.bannerUrl.isNotEmpty
                                                          ? Image.network(
                                                              movie.bannerUrl,
                                                              fit: BoxFit.cover,
                                                              width: double.infinity,
                                                              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2C2C2C)),
                                                            )
                                                          : Container(color: const Color(0xFF2C2C2C)),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black.withOpacity(0.4),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            movie.rating.toString(),
                                                            style: const TextStyle(
                                                              color: Colors.white,
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
                                              const SizedBox(height: 12),
                                              Text(
                                                movie.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${movie.categories.isNotEmpty ? movie.categories.first : 'Movie'} • ${movie.duration}',
                                                style: const TextStyle(
                                                  color: Color(0xFFB0B0B0),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ),

                              const SizedBox(height: 32),

                              // Popular Movies
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Popular Movies',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const MoviesScreen(
                                              title: 'Popular Movies',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'See all',
                                        style: TextStyle(
                                          color: Color(0xFF4FC3F7),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              _allMovies.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Center(
                                        child: Text(
                                          'No movies available',
                                          style: TextStyle(color: Color(0xFFB0B0B0)),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                  itemCount: _filteredMovies.length > 3 ? 3 : _filteredMovies.length,
                                  itemBuilder: (context, index) {
                                    final movie = _filteredMovies[index];
                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: index < _filteredMovies.length - 1 ? 16 : 0),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2C2C2C),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 85,
                                              height: 110,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: movie.bannerUrl.isNotEmpty
                                                    ? Image.network(
                                                        movie.bannerUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A1A1A)),
                                                      )
                                                    : Container(color: const Color(0xFF1A1A1A)),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          movie.categories.isNotEmpty ? movie.categories.first.toUpperCase() : 'MOVIE',
                                                          style: const TextStyle(
                                                            color: Color(0xFFF5F5F5),
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            letterSpacing: 1,
                                                          ),
                                                        ),
                                                      ),
                                                      const Icon(Icons.bookmark_border, color: Color(0xFFB0B0B0), size: 22),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    movie.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        movie.rating.toString(),
                                                        style: const TextStyle(
                                                          color: Color(0xFFF5F5F5),
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '(2.1k)',
                                                        style: const TextStyle(
                                                          color: Color(0xFFB0B0B0),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        '•',
                                                        style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        movie.duration,
                                                        style: const TextStyle(
                                                          color: Color(0xFFB0B0B0),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
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

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}