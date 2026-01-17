import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../repository/movie_repository.dart';

class MovieDetailViewModel extends ChangeNotifier {
  final MovieRepository repository;

  MovieDetailViewModel(this.repository);

  Movie? movie;
  bool isLoading = false;
  String? errorMessage;

  int? currentMovieId;

  Future<void> loadMovieById(int id) async {

    if (currentMovieId == id && movie != null) return;

    currentMovieId = id;
    isLoading = true;
    errorMessage = null;
    movie = null;
    notifyListeners();

    try {
      movie = await repository.getMovieById(id);
      if (movie == null) {
        errorMessage = "Movie not found.";
      }
    } catch (e) {
      errorMessage = "Failed to load movie: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
