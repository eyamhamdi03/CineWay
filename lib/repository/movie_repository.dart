import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/movie.dart';
import '../data/mock_movies.dart';

class MovieRepository {
  final String baseUrl = "http://127.0.0.1:8000/api/v1";

  // Get all movies
  Future<List<Movie>> getAllMovies() async {

     final response = await http.get(Uri.parse("$baseUrl/movies"));
     final data = jsonDecode(response.body);
     if (response.statusCode == 200) {
       final data = jsonDecode(response.body);

       final List list = data as List;

       return list.map((json) => Movie.fromJson(json)).toList();
     } else {
       throw Exception('Failed to search movies: ${response.statusCode}');
     }
  }


  // Get movie by ID
  Future<Movie> getMovieById(int id) async {
    final uri = Uri.parse("$baseUrl/movies/$id");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Movie.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load movie $id");
    }
  }

  // Search movie by title or categories
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    final allMovies = await getAllMovies();
    final q = query.toLowerCase();

    return allMovies.where((movie) {
      final titleMatch = movie.title.toLowerCase().contains(q);

      final categoryMatch = movie.categories.any(
            (c) => c.toLowerCase().contains(q),
      );

      return titleMatch || categoryMatch;
    }).toList();
  }

}
