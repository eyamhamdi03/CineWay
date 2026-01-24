import 'package:cineway/core/colors.dart';
import 'package:cineway/screens/reviews_screen.dart';
import 'package:cineway/screens/showtimes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../viewmodel/movie/movie_detail_viewmodel.dart';
import '../viewmodel/movie/movie_review_viewmodel.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool _expandSynopsis = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MovieDetailViewModel>();

    if (vm.currentMovieId != widget.movieId && !vm.isLoading) {
      Future.microtask(() => vm.loadMovieById(widget.movieId));
    }

    if (vm.isLoading || vm.movie == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: AppColors.dodgerBlue)),
      );
    }

    final movie = vm.movie!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // HERO IMAGE
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(movie.bannerUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Image.network(
                        movie.bannerUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.5), const Color(0xFF121212).withOpacity(0.9)],
                          ),
                        ),
                      ),
                    ),
                    // Back & Favorite buttons
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _isFavorite = !_isFavorite);
                              // TODO: Save to database
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Play button
                    Positioned.fill(
                      child: Center(
                        child: GestureDetector(
                          onTap: movie.trailerUrl?.isNotEmpty == true
                              ? () => _playTrailer(movie.trailerUrl!)
                              : null,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.dodgerBlue.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.dodgerBlue.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Content rounded container
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF121212),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                      border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag indicator
                          Center(
                            child: Container(
                              width: 48,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Title
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Meta row (year · duration · rating)
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 14, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 4),
                              Text('${movie.releaseYear}', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                              const SizedBox(width: 12),
                              Container(width: 2, height: 2, decoration: const BoxDecoration(color: Color(0xFF4B5563), shape: BoxShape.circle)),
                              const SizedBox(width: 12),
                              const Icon(Icons.schedule, size: 14, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 4),
                              Text(movie.duration, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                              const SizedBox(width: 12),
                              Container(width: 2, height: 2, decoration: const BoxDecoration(color: Color(0xFF4B5563), shape: BoxShape.circle)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(movie.rating, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Genres
                          Wrap(
                            spacing: 8,
                            children: movie.categories.map((cat) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(cat, style: const TextStyle(fontSize: 11, color: AppColors.dodgerBlue, fontWeight: FontWeight.bold)),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),
                          // Rating, Director, Language Cards
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                            children: [
                              _buildInfoCard('⭐ ${movie.rating}', 'RATING'),
                              _buildInfoCard(movie.director ?? 'N/A', 'DIRECTOR'),
                              _buildInfoCard(movie.language ?? 'N/A', 'LANGUAGE'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Synopsis with expand/collapse
                          const Text('Synopsis', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            movie.description,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), height: 1.6),
                            maxLines: _expandSynopsis ? null : 2,
                            overflow: _expandSynopsis ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                          if (movie.description.split('\n').length > 2 || movie.description.length > 100)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => setState(() => _expandSynopsis = !_expandSynopsis),
                                child: Text(
                                  _expandSynopsis ? 'Read Less' : 'Read More',
                                  style: const TextStyle(color: AppColors.dodgerBlue, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Cast
                          if (movie.cast.isNotEmpty) ...[
                            const Text('Cast', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: movie.cast.take(5).map((actor) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '• ${actor.name}',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                                ),
                              )).toList(),
                            ),
                            if (movie.cast.length > 5)
                              TextButton(
                                onPressed: () {},
                                child: const Text('See All Cast', style: TextStyle(color: AppColors.dodgerBlue, fontWeight: FontWeight.bold)),
                              ),
                            const SizedBox(height: 24),
                          ],
                          // Writers
                          if (movie.writers != null && movie.writers!.isNotEmpty) ...[
                            const Text('Writers', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              movie.writers!.join(', '),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), height: 1.6),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fixed Booking Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF121212).withOpacity(0), const Color(0xFF121212)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dodgerBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ShowtimesScreen(movieTitle: movie.title)),
                  );
                },
                child: const Text('Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF121212))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _playTrailer(String trailerUrl) async {
    final uri = Uri.parse(trailerUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch trailer')),
      );
    }


}  }