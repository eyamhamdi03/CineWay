import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../repository/cinema_repository.dart';
import '../repository/showtime_repository.dart';
import '../repository/movie_repository.dart';
import '../models/cinema.dart';
import '../models/screening.dart';
import '../models/movie.dart';
import 'details_screen.dart';

class CinemaDetailsScreen extends StatelessWidget {
  final int cinemaId;
  CinemaDetailsScreen({super.key, required this.cinemaId});

  final _repo = CinemaRepository();
  final _showtimeRepo = ShowtimeRepository();
  final _movieRepo = MovieRepository();

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
      future: _repo.getCinemaById(cinemaId),
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
                          gradient: LinearGradient(
                            colors: [AppColors.nileBlue, AppColors.dodgerBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(child: Icon(Icons.movie_filter, color: Colors.white70, size: 64)),
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

                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: const Text('Showtimes Today', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Screening>>(
                    future: _showtimeRepo.getShowtimesByCinema(cinemaId: cinemaId),
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
}
