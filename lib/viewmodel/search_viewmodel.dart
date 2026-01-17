import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../models/cinema.dart';
import '../../repository/movie_repository.dart';
import '../../repository/cinema_repository.dart';
import 'dart:async' show Timer, unawaited;

class SearchViewModel extends ChangeNotifier {
  final MovieRepository movieRepo;
  final CinemaRepository cinemaRepo;
  final TextEditingController searchController = TextEditingController();

  SearchViewModel({
    required this.movieRepo,
    required this.cinemaRepo,
  });

  List<Movie> movieResults = [];
  List<Cinema> cinemaResults = [];

  bool isLoading = false;

  Timer? _debounce;

  void onSearchChanged(String query) {
    _debounce?.cancel();

    final q = query.trim();

    if (q.isEmpty) {
      movieResults = [];
      cinemaResults = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 200), () {
      unawaited(search(q));
    });
  }


  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      movieResults.clear();
      cinemaResults.clear();
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    movieResults = await movieRepo.searchMovies(query);
    cinemaResults = await cinemaRepo.searchCinemas(query);

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

}
