import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../models/movie.dart';
import '../repository/movie_repository.dart';
import '../viewmodel/favorites/favorite_movies_viewmodel.dart';
import '../viewmodel/favorites/saved_movies_viewmodel.dart';
import '../viewmodel/session/session_viewmodel.dart';
import 'details_screen.dart';

class LikedMoviesScreen extends StatefulWidget {
  const LikedMoviesScreen({super.key});

  @override
  State<LikedMoviesScreen> createState() => _LikedMoviesScreenState();
}

class _LikedMoviesScreenState extends State<LikedMoviesScreen> {
  final MovieRepository _repo = MovieRepository();
  bool _loading = true;
  String? _error;
  List<Movie> _allMovies = [];
  String _filter = 'All';

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

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteMoviesViewModel>();
    final saved = context.watch<SavedMoviesViewModel>();
    final session = context.watch<SessionViewModel>();
    final favoriteIds = favorites.favoriteIds.toSet();
    final savedIds = saved.savedIds.toSet();

    final likedMovies = _allMovies.where((m) => favoriteIds.contains(m.id)).toList();
    final savedMovies = _allMovies.where((m) => savedIds.contains(m.id)).toList();
    final displayMovies = _filter == 'Liked'
        ? likedMovies
        : _filter == 'Saved'
            ? savedMovies
            : _allMovies.where((m) => favoriteIds.contains(m.id) || savedIds.contains(m.id)).toList();

    final userName = (session.user?.fullName?.isNotEmpty == true) ? session.user!.fullName! : 'User';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text('$userName Movies', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dodgerBlue))
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
              : displayMovies.isEmpty
                  ? const Center(
                      child: Text('No movies yet', style: TextStyle(color: Colors.white70)),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Row(
                            children: [
                              _filterChip('All'),
                              const SizedBox(width: 8),
                              _filterChip('Liked'),
                              const SizedBox(width: 8),
                              _filterChip('Saved'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: displayMovies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final movie = displayMovies[index];
                        return ListTile(
                          tileColor: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              movie.bannerUrl,
                              width: 52,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 52,
                                height: 72,
                                color: const Color(0xFF2A2A2A),
                                child: const Icon(Icons.movie, color: Colors.white54),
                              ),
                            ),
                          ),
                          title: Text(movie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${movie.releaseYear} • ${movie.duration}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              favoriteIds.contains(movie.id) ? Icons.favorite : Icons.bookmark,
                              color: favoriteIds.contains(movie.id) ? Colors.redAccent : AppColors.dodgerBlue,
                            ),
                            onPressed: () {
                              if (favoriteIds.contains(movie.id)) {
                                favorites.removeFavorite(movie.id);
                              } else if (savedIds.contains(movie.id)) {
                                saved.removeSaved(movie.id);
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailsScreen(movieId: movie.id),
                              ),
                            );
                          },
                        );
                      },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.dodgerBlue : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFB0B0B0),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
