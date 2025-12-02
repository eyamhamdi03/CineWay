import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/screening.dart';

class ScreeningRepository {
  final String baseUrl = "http://localhost:8000/api/v1";

  // Get screenings (filter by cinema, movie or room)
  Future<List<Screening>> getScreenings({
    int? cinemaId,
    int? movieId,
    int? roomId,
  }) async {

    // Example when backend is ready:
    // final uri = Uri.parse("$baseUrl/screenings").replace(queryParameters: {
    //   if (cinemaId != null) "cinema_id": "$cinemaId",
    //   if (movieId != null) "movie_id": "$movieId",
    //   if (roomId != null) "room_id": "$roomId",
    // });
    // final response = await http.get(uri);
    // final data = jsonDecode(response.body);
    // return (data as List).map((s) => Screening.fromJson(s)).toList();

    await Future.delayed(const Duration(milliseconds: 250));
    return [];  // until mock
  }

  // Get NOW SHOWING movies for a cinema (returns movie IDs)
  Future<List<int>> getNowShowingMovieIds(int cinemaId) async {
    final screenings = await getScreenings(cinemaId: cinemaId);

    final movieIds = screenings.map((s) => s.movieId).toSet().toList();
    return movieIds;
  }
}
