import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/cinema.dart';
import '../../repository/cinema_repository.dart';
import '../../repository/screening_repository.dart';
import '../gps/gps_viewmodel.dart';
import '../../models/movie.dart';
import '../../repository/movie_repository.dart';

class CinemaListViewModel extends ChangeNotifier {
  final CinemaRepository cinemaRepo;
  final MovieRepository movieRepo;
  final ScreeningRepository screeningRepo;
  final GPSViewModel gps;

  CinemaListViewModel({
    required this.cinemaRepo,
    required this.movieRepo,
    required this.screeningRepo,
    required this.gps,
  });

  List<Cinema> cinemas = [];
  bool isLoading = false;

  Timer? _debounce;
  final TextEditingController searchCtrl = TextEditingController();

  /// Load all cinemas, sorted by distance
  Future<void> loadCinemas() async {
    isLoading = true;
    notifyListeners();

    cinemas = await cinemaRepo.getAllCinemas();

    // Sort by distance if GPS enabled
    if (gps.userPosition != null) {
      cinemas.sort((a, b) =>
          gps.distanceToCinema(a).compareTo(gps.distanceToCinema(b))
      );
    }

    isLoading = false;
    notifyListeners();
  }

  /// Debounced search
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchCinema(query);
    });
  }

  /// Execute search
  Future<void> searchCinema(String query) async {
    isLoading = true;
    notifyListeners();

    // Reset if query empty
    if (query.trim().isEmpty) {
      cinemas = await cinemaRepo.getAllCinemas();
    } else {
      cinemas = await cinemaRepo.searchCinemas(query);
    }

    // Sort by distance again
    if (gps.userPosition != null) {
      cinemas.sort((a, b) =>
          gps.distanceToCinema(a).compareTo(gps.distanceToCinema(b))
      );
    }

    isLoading = false;
    notifyListeners();
  }
}
