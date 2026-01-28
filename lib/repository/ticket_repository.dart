import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/ticket.dart';

class TicketRepository {
  String get _baseUrl => ApiConfig.baseUrl;

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
      };

  /// GET /tickets/my-tickets
  Future<List<Ticket>> getMyTickets({required String token}) async {
    final uri = Uri.parse('$_baseUrl/tickets/my-tickets');
    final resp = await http.get(uri, headers: _headers(token));

    if (resp.statusCode != 200) {
      throw HttpException('Failed to load my tickets: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! List) {
      throw const FormatException('Unexpected my-tickets response shape');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Ticket.fromJson)
        .toList();
  }

  /// POST /tickets/{ticket_id}/confirm-payment
  ///
  /// Confirms payment for a ticket (moves status from pending -> confirmed).
  Future<Ticket> confirmPayment({
    required String token,
    required int ticketId,
    required String paymentMethod,
    String? transactionId,
  }) async {
    final uri = Uri.parse('$_baseUrl/tickets/$ticketId/confirm-payment');
    final resp = await http.post(
      uri,
      headers: {
        ..._headers(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'payment_method': paymentMethod,
        if (transactionId != null && transactionId.isNotEmpty) 'transaction_id': transactionId,
      }),
    );

    if (resp.statusCode != 200) {
      throw HttpException('Failed to confirm payment: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected confirm-payment response shape');
    }
    return Ticket.fromJson(decoded);
  }
}

