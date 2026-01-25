import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repository/movie_repository.dart';
import 'details_screen.dart';
import '../core/colors.dart';

class MoviesScreen extends StatefulWidget {
  final String? title;
  final String? category;
  final bool nowInCinemasOnly;

  const MoviesScreen({super.key, this.title, this.category, this.nowInCinemasOnly = false});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final _repo = MovieRepository();
  bool _loading = true;
  String? _error;
  List<Movie> _movies = [];

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
      List<Movie> filtered = movies;

      if (widget.nowInCinemasOnly) {
        final today = DateTime.now();
        filtered = movies.where((m) {
          final d = m.releaseDate;
          if (d == null) return true;
          return !d.isAfter(DateTime(today.year, today.month, today.day));
        }).toList();
      }

      if (widget.category != null && widget.category != 'All') {
        filtered = filtered.where((m) {
          return m.categories.any(
            (cat) => cat.toLowerCase() == widget.category!.toLowerCase()
          );
        }).toList();
      }

      setState(() => _movies = filtered);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922).withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? 'All Movies',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dodgerBlue))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMovies,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _movies.isEmpty
                  ? const Center(
                      child: Text(
                        'No movies available',
                        style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _movies.length,
                      itemBuilder: (context, index) {
                        final movie = _movies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailsScreen(movieId: movie.id),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: movie.bannerUrl.isNotEmpty
                                        ? Image.network(
                                            movie.bannerUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: Colors.grey.shade800,
                                              child: const Icon(Icons.movie, size: 50, color: Colors.white70),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey.shade800,
                                            child: const Icon(Icons.movie, size: 50, color: Colors.white70),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                movie.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.rating,
                                    style: const TextStyle(
                                      color: Color(0xFFB0B0B0),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      movie.categories.isNotEmpty ? movie.categories.first : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFB0B0B0),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
