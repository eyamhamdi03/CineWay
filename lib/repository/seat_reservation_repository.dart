import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/model.dart';

class SeatReservationRepository {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }

  Future<ToggleSeatReservationResponse> toggleSeatReservation({
    required int screeningId,
    required int seatId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/seat-reservations/toggle');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'screening_id': screeningId,
        'seat_id': seatId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ToggleSeatReservationResponse.fromJson(data);
    } else {
      throw Exception('Failed to toggle seat reservation: ${response.body}');
    }
  }

  Future<SeatAvailabilityResponse> getSeatAvailabilityForUser({
    required int screeningId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/seat-reservations/screening/$screeningId/availability/me');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SeatAvailabilityResponse.fromJson(data);
    } else {
      throw Exception('Failed to get seat availability: ${response.body}');
    }
  }

  Future<void> cancelReservation({
    required int screeningId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/seat-reservations/screening/$screeningId/my-reservations');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel reservation: ${response.body}');
    }
  }
}
