import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/cinema.dart';
import '../data/mock_cinemas.dart';
import '../config/api_config.dart';

class CinemaRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // Get all cinemas
  Future<List<Cinema>> getAllCinemas() async {
    final response = await http.get(Uri.parse("$baseUrl/cinemas"));
    if (response.statusCode != 200) {
      throw Exception('Failed to search cinemas: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    // API may return a raw list or wrap it in a map like {"data": [...]} or {"cinemas": [...]}
    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map) {
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      } else if (decoded['cinemas'] is List) {
        list = decoded['cinemas'] as List;
      }
    }

    if (list == null) {
      throw Exception('Unexpected cinemas response shape');
    }

    return list.map((json) => Cinema.fromJson(json as Map<String, dynamic>)).toList();
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
