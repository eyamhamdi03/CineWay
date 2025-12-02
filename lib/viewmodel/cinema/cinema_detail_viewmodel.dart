import 'package:flutter/material.dart';
import '../../models/cinema.dart';
import '../../repository/cinema_repository.dart';
import '../../repository/screening_repository.dart';
import '../../repository/movie_repository.dart';
import '../../models/movie.dart';

class CinemaDetailViewModel extends ChangeNotifier {
  final CinemaRepository cinemaRepo;
  final ScreeningRepository screeningRepo;
  final MovieRepository movieRepo;

  CinemaDetailViewModel({
    required this.cinemaRepo,
    required this.screeningRepo,
    required this.movieRepo,
  });

  Cinema? cinema;
  List<Movie> nowShowing = [];
  bool isLoading = false;

  Future<void> loadCinemaById(int id) async {
    isLoading = true;
    notifyListeners();

    // Load cinema details
    cinema = await cinemaRepo.getCinemaById(id);

    // Load screenings → movie IDs → movie details
    final screeningMovieIds =
    await screeningRepo.getNowShowingMovieIds(id);

    nowShowing = [];

    for (var mId in screeningMovieIds) {
      final movie = await movieRepo.getMovieById(mId);
      if (movie != null) nowShowing.add(movie);
    }

    isLoading = false;
    notifyListeners();
  }
}
