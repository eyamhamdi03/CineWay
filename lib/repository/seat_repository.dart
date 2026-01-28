import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/seat.dart';

class SeatRepository {
  String get _baseUrl => ApiConfig.baseUrl;

  /// GET /rooms/{room_id}/seats/
  Future<List<Seat>> listRoomSeats(int roomId) async {
    final uri = Uri.parse('$_baseUrl/rooms/$roomId/seats/');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw HttpException('Failed to load room seats: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! List) {
      throw const FormatException('Unexpected seats response shape');
    }
    return decoded.whereType<Map<String, dynamic>>().map(Seat.fromJson).toList();
  }
}

