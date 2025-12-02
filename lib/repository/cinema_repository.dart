import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/cinema.dart';
import '../data/mock_cinemas.dart';

class CinemaRepository {
  final String baseUrl = "http://127.0.0.1:8000/api/v1";

  // Get all cinemas
  Future<List<Cinema>> getAllCinemas() async {
    final response = await http.get(Uri.parse("$baseUrl/cinemas"));
     final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List list = data as List;

      return list.map((json) => Cinema.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search cinemas: ${response.statusCode}');
    }
  }


  // Get cinema by ID
  Future<Cinema?> getCinemaById(int id) async {
     final response = await http.get(Uri.parse("$baseUrl/cinemas/$id"));
     if (response.statusCode == 200) {
       return Cinema.fromJson(jsonDecode(response.body));
     } else {
       throw Exception("Failed to load movie $id");
     }
  }

  // Search cinema
  Future<List<Cinema>> searchCinemas(String query) async {
    if (query.trim().isEmpty) return [];

    final allCinemas = await getAllCinemas();
    final q = query.toLowerCase();

    return allCinemas.where((cinema) {
      return cinema.name.toLowerCase().contains(q) ||
          cinema.address.toLowerCase().contains(q) ||
          cinema.city.toLowerCase().contains(q) ||
          cinema.amenities.any((a) => a.toLowerCase().contains(q));
    }).toList();
  }
}
