import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/showtime.dart';

class ShowtimeApiRepository {
  String get _baseUrl => ApiConfig.baseUrl;

  Future<Showtime> getShowtime(int id) async {
    final uri = Uri.parse('$_baseUrl/showtimes/$id');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw HttpException('Failed to load showtime: ${resp.statusCode} ${resp.body}');
    }
    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected showtime response shape');
    }
    return Showtime.fromJson(decoded);
  }
}

