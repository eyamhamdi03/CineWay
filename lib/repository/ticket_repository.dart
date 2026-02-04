import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ticket.dart';

class TicketRepository {
  final String baseUrl = ApiConfig.baseUrl;

  /// Get all tickets for the current user
  Future<List<Ticket>> getMyTickets(String token) async {
    final uri = Uri.parse('$baseUrl/tickets/my-tickets');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load tickets: ${response.statusCode} ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Ticket.fromJson(json)).toList();
  }

  /// Get a specific ticket by ID
  Future<Ticket> getTicket(int ticketId, String token) async {
    final uri = Uri.parse('$baseUrl/tickets/$ticketId');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load ticket: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    return Ticket.fromJson(data);
  }

  /// Book tickets for a screening
  Future<List<Ticket>> bookTickets({
    required int screeningId,
    required List<int> seatIds,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/tickets/book');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'screening_id': screeningId,
        'seat_ids': seatIds,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to book tickets: ${response.statusCode} ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Ticket.fromJson(json)).toList();
  }

  /// Cancel a ticket
  Future<void> cancelTicket(int ticketId, String token) async {
    final uri = Uri.parse('$baseUrl/tickets/$ticketId');
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to cancel ticket: ${response.statusCode} ${response.body}');
    }
  }

  /// Confirm payment for a ticket
  Future<Ticket> confirmPayment({
    required int ticketId,
    required String paymentMethod,
    String? transactionId,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/tickets/$ticketId/confirm-payment');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'payment_method': paymentMethod,
        if (transactionId != null) 'transaction_id': transactionId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to confirm payment: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    return Ticket.fromJson(data);
  }
}
