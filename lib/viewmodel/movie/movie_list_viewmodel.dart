import 'dart:async';
import 'package:flutter/material.dart';
import '../../repository/movie_repository.dart';
import '../../models/movie.dart';

class MovieListViewModel extends ChangeNotifier {
  final MovieRepository repository;

  MovieListViewModel(this.repository);

  List<Movie> movies = [];
  bool isLoading = false;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  // Load all movies
  Future<void> loadMovies() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      movies = await repository.getAllMovies();
    } catch (e) {
      errorMessage = "Unable to load movies.";
    }

    isLoading = false;
    notifyListeners();
  }

  // Debounced search
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchMovies(query);
    });
  }

  Future<void> searchMovies(String query) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (query.trim().isEmpty) {
        movies = await repository.getAllMovies();
      } else {
        movies = await repository.searchMovies(query);
      }
    } catch (e) {
      errorMessage = "Search failed.";
    }

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
