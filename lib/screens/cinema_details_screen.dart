import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../repository/cinema_repository.dart';
import '../repository/showtime_repository.dart';
import '../repository/movie_repository.dart';
import '../models/cinema.dart';
import '../models/screening.dart';
import '../models/movie.dart';
import '../models/review.dart';
import 'details_screen.dart';

class CinemaDetailsScreen extends StatefulWidget {
  final int cinemaId;
  CinemaDetailsScreen({super.key, required this.cinemaId});

  @override
  State<CinemaDetailsScreen> createState() => _CinemaDetailsScreenState();
}

class _CinemaDetailsScreenState extends State<CinemaDetailsScreen> {
  late final _repo = CinemaRepository();
  late final _showtimeRepo = ShowtimeRepository();
  late final _movieRepo = MovieRepository();

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _amenityTile(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFF141A20), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: const Color(0xFF213036), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.dodgerBlue),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _buildPoster(Movie? movie) {
    final url = movie?.bannerUrl ?? '';
    if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 60, color: AppColors.jumbo),
      );
    }
    if (url.isNotEmpty) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 60, color: AppColors.jumbo),
      );
    }
    return const Icon(Icons.movie, size: 60, color: AppColors.jumbo);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Cinema?>(
      future: _repo.getCinemaById(widget.cinemaId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.mirage,
            body: Center(child: CircularProgressIndicator(color: AppColors.dodgerBlue)),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            backgroundColor: AppColors.mirage,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Failed to load cinema', style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 8),
                    Text(snap.error.toString(), style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: () => Navigator.maybePop(context), child: const Text('Back')),
                  ],
                ),
              ),
            ),
          );
        }

        final cinema = snap.data!;

        return Scaffold(
          backgroundColor: AppColors.mirage,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage('assets/cinema_banner.jpg'), fit: BoxFit.cover),),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 14,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cinema.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text(
                              cinema.address.isNotEmpty ? cinema.address : cinema.city,
                              style: const TextStyle(color: AppColors.jumbo),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showSnack(context, 'Open maps (demo)'),
                            icon: const Icon(Icons.navigation, color: Colors.white),
                            label: const Text('Get Directions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dodgerBlue, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showSnack(context, cinema.phone.isNotEmpty ? 'Call ${cinema.phone} (demo)' : 'Call cinema (demo)'),
                            icon: const Icon(Icons.phone, color: Colors.white),
                            label: const Text('Call Cinema', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A3942)), backgroundColor: const Color(0xFF141A20), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: const Text('Amenities', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: (cinema.amenities.isNotEmpty ? cinema.amenities : ['Accessible']).map((a) {
                        final icon = a.toLowerCase().contains('imax')
                            ? Icons.theaters
                            : a.toLowerCase().contains('dolby')
                                ? Icons.speaker
                                : a.toLowerCase().contains('parking')
                                    ? Icons.local_parking
                                    : a.toLowerCase().contains('reclin')
                                        ? Icons.chair
                                        : a.toLowerCase().contains('access')
                                            ? Icons.accessible
                                            : Icons.movie;
                        return SizedBox(width: 160, child: _amenityTile(icon, a));
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddReviewDialog(context, cinema),
                            icon: const Icon(Icons.edit),
                            label: const Text('Add Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dodgerBlue, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAllReviews(context, cinema),
                            icon: const Icon(Icons.star, color: AppColors.dodgerBlue),
                            label: const Text('See All Reviews', style: TextStyle(color: AppColors.dodgerBlue, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.dodgerBlue), backgroundColor: const Color(0xFF141A20), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: const Text('Showtimes Today', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Screening>>(
                    future: _showtimeRepo.getShowtimesByCinema(cinemaId: widget.cinemaId),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator(color: AppColors.dodgerBlue)));
                      }
                      if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                        return SizedBox(
                          height: 120,
                          child: Center(
                            child: Text(
                              snap.hasError ? 'Error loading showtimes' : 'No showtimes available',
                              style: const TextStyle(color: AppColors.jumbo),
                            ),
                          ),
                        );
                      }

                      final showtimes = snap.data!;
                      return SizedBox(
                        height: 260,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final showtime = showtimes[index];
                            final time = showtime.screeningTime;
                            final dateStr = '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
                            final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            return FutureBuilder<Movie?>(
                              future: _movieRepo.getMovieById(showtime.movieId),
                              builder: (context, movieSnap) {
                                final movie = movieSnap.data;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MovieDetailsScreen(movieId: showtime.movieId),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 140,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 140,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFF141A20)),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: _buildPoster(movie),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          movie?.title ?? 'Loading...',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(dateStr, style: const TextStyle(color: AppColors.dodgerBlue, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(timeStr, style: const TextStyle(color: AppColors.jumbo, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemCount: showtimes.length,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3942),
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
                        Text('${review.rating}', style: const TextStyle(fontSize: 12, color: AppColors.jumbo)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: const TextStyle(fontSize: 12, color: AppColors.jumbo, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, Cinema cinema) {
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
                          'Share Your Experience',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help others discover great cinemas',
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
                          'How would you rate this cinema?',
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
                            hintText: 'Share your thoughts about facilities, service, and atmosphere...',
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

  void _showAllReviews(BuildContext context, Cinema cinema) {
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
              child: Text('All Reviews (${cinema.reviews.length})', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: cinema.reviews.isEmpty
                  ? const Center(child: Text('No reviews yet', style: TextStyle(color: AppColors.jumbo)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: cinema.reviews.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildReviewCard(cinema.reviews[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }}
