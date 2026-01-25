import 'package:cineway/core/colors.dart';
import 'package:cineway/screens/reviews_screen.dart';
import 'package:cineway/screens/showtimes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/movie.dart';
import '../models/review.dart';
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
                          // Review Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddReviewDialog(context, movie),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Add Review'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.dodgerBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showAllReviews(context, movie),
                                  icon: const Icon(Icons.star, color: AppColors.dodgerBlue),
                                  label: const Text('See All Reviews', style: TextStyle(color: AppColors.dodgerBlue)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: AppColors.dodgerBlue),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
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
                          // Recent Reviews
                          if (movie.reviews.isNotEmpty) ...[                              const Text('Recent Reviews', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ...movie.reviews.take(3).map((review) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildReviewCard(review),
                            )).toList(),
                            if (movie.reviews.length > 3)
                              Center(
                                child: TextButton(
                                  onPressed: () => _showAllReviews(context, movie),
                                  child: const Text('View All Reviews', style: TextStyle(color: AppColors.dodgerBlue, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
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
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.reviewerAvatar),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating.toInt() ? Icons.star : Icons.star_outline,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('${review.rating}', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, Movie movie) {
    double rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dodgerBlue.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.dodgerBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.star, color: AppColors.dodgerBlue, size: 28),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Share Your Thoughts',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help others discover great movies',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF2A2A2A), height: 1),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating Section
                        const Text(
                          'How would you rate this movie?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => GestureDetector(
                                onTap: () => setState(() => rating = (index + 1).toDouble()),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: AnimatedScale(
                                    scale: index < rating ? 1.2 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                      color: index < rating ? Colors.amber : Colors.white.withOpacity(0.3),
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '${rating.toStringAsFixed(0)} / 5.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Comment Section
                        const Text(
                          'Tell us more about your experience',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: commentController,
                          maxLines: 5,
                          maxLength: 500,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Share your thoughts, favorite scenes, or recommendations...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2A2A2A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.dodgerBlue, width: 2),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            counterStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF2A2A2A), height: 1),
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF2A2A2A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [AppColors.dodgerBlue, AppColors.dodgerBlue.withOpacity(0.8)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.dodgerBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (commentController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please write your review')),
                                  );
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Review submitted successfully! 🎉'),
                                    backgroundColor: Colors.green[600],
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                Navigator.pop(context);
                                commentController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Submit Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAllReviews(BuildContext context, Movie movie) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('All Reviews (${movie.reviews.length})', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: movie.reviews.isEmpty
                  ? const Center(child: Text('No reviews yet', style: TextStyle(color: Color(0xFF9CA3AF))))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: movie.reviews.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildReviewCard(movie.reviews[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}