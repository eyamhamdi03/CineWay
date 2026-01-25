import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';
import '../models/screening.dart';

class ShowtimeRepository {
  final String _baseUrl = ApiConfig.baseUrl;

  /// Get showtimes for a specific cinema
  Future<List<Screening>> getShowtimesByCinema({
    required int cinemaId,
    String? date,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/showtimes').replace(
        queryParameters: {
          'cinema_id': cinemaId.toString(),
          'skip': skip.toString(),
          'limit': limit.toString(),
          if (date != null) 'date': date,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Screening.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load showtimes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching showtimes: $e');
    }
  }

  /// Get showtimes for a specific movie with detailed cinema info
  Future<List<Map<String, dynamic>>> getShowtimesByMovieDetailed({
    required int movieId,
    String? date,
    int skip = 0,
    int limit = 200,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/screenings').replace(
        queryParameters: {
          'movie_id': movieId.toString(),
          'skip': skip.toString(),
          'limit': limit.toString(),
          if (date != null) 'date': date,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load showtimes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching showtimes: $e');
    }
  }

  /// Get a specific showtime by ID
  Future<Screening> getShowtimeById(int showtimeId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/showtimes/$showtimeId'));

      if (response.statusCode == 200) {
        return Screening.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load showtime: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching showtime: $e');
    }
  }

  /// Get available seats for a showtime
  Future<List<dynamic>> getShowtimeSeats(int showtimeId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/showtimes/$showtimeId/seats'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load seats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching seats: $e');
    }
  }
}
