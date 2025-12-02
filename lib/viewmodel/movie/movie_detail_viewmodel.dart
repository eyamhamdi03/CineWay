import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../repository/movie_repository.dart';

class MovieDetailViewModel extends ChangeNotifier {
  final MovieRepository repository;

  MovieDetailViewModel(this.repository);

  Movie? movie;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadMovieById(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      movie = await repository.getMovieById(id);

      if (movie == null) {
        errorMessage = "Movie not found.";
      }
    } catch (e) {
      errorMessage = "Failed to load movie.";
    }

    isLoading = false;
    notifyListeners();
  }
}
