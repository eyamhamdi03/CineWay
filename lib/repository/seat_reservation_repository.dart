import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Seat status values as used by the backend.
enum SeatStatus {
  available,
  booked,
  held,
  reserved,
  reservedByMe,
}

SeatStatus _seatStatusFromString(String value) {
  switch (value) {
    case 'booked':
      return SeatStatus.booked;
    case 'held':
      return SeatStatus.held;
    case 'reserved':
      return SeatStatus.reserved;
    case 'reserved_by_me':
      return SeatStatus.reservedByMe;
    case 'available':
    default:
      return SeatStatus.available;
  }
}

/// Public helper so other layers (e.g., WebSocket service) can reuse the
/// backend string mapping without duplicating it.
SeatStatus seatStatusFromString(String value) => _seatStatusFromString(value);

String _seatStatusToString(SeatStatus status) {
  switch (status) {
    case SeatStatus.booked:
      return 'booked';
    case SeatStatus.held:
      return 'held';
    case SeatStatus.reserved:
      return 'reserved';
    case SeatStatus.reservedByMe:
      return 'reserved_by_me';
    case SeatStatus.available:
    default:
      return 'available';
  }
}

class SeatWithStatus {
  final int seatId;
  final SeatStatus status;
  final int? heldByUser;
  final int? reservedBy;
  final bool isMine;
  final DateTime? expiresAt;
  final String? rowLabel;
  final int? seatNumber;
  final String? seatType;

  SeatWithStatus({
    required this.seatId,
    required this.status,
    this.heldByUser,
    this.reservedBy,
    this.isMine = false,
    this.expiresAt,
    this.rowLabel,
    this.seatNumber,
    this.seatType,
  });

  factory SeatWithStatus.fromJson(Map<String, dynamic> json) {
    // Backend can either flatten the seat or nest it under "seat"
    final seat = json['seat'] as Map<String, dynamic>?;
    final rowLabel = seat != null ? seat['row_label'] as String? : json['row_label'] as String?;
    final seatNumber = seat != null ? seat['seat_number'] as int? : json['seat_number'] as int?;
    final seatType = seat != null ? seat['seat_type'] as String? : json['seat_type'] as String?;

    final statusStr = (json['status'] ?? 'available').toString();

    return SeatWithStatus(
      seatId: (seat != null ? seat['id'] : json['seat_id']) as int,
      status: _seatStatusFromString(statusStr),
      heldByUser: (json['reserved_by'] ?? json['held_by_user']) as int?,
      reservedBy: json['reserved_by'] as int?,
      isMine: json['is_mine'] == true,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      rowLabel: rowLabel,
      seatNumber: seatNumber,
      seatType: seatType,
    );
  }
}

class SeatAvailabilityResponse {
  final int screeningId;
  final List<SeatWithStatus> seats;

  SeatAvailabilityResponse({
    required this.screeningId,
    required this.seats,
  });
}

class ToggleSeatResponse {
  final String action; // 'reserved' | 'unreserved'
  final String? message;
  final List<int> seatIds;
  final int? expiresInMinutes;
  final ReservationDetail? reservation;

  ToggleSeatResponse({
    required this.action,
    this.message,
    required this.seatIds,
    this.expiresInMinutes,
    this.reservation,
  });

  factory ToggleSeatResponse.fromJson(Map<String, dynamic> json) {
    return ToggleSeatResponse(
      action: json['action']?.toString() ?? 'reserved',
      message: json['message'] as String?,
      seatIds: (json['seat_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          <int>[],
      expiresInMinutes: (json['expires_in_minutes'] as num?)?.toInt(),
      reservation: json['reservation'] != null
          ? ReservationDetail.fromJson(json['reservation'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReservationDetail {
  final int id;
  final int screeningId;
  final int seatId;
  final int userId;
  final String status;
  final DateTime expiresAt;

  ReservationDetail({
    required this.id,
    required this.screeningId,
    required this.seatId,
    required this.userId,
    required this.status,
    required this.expiresAt,
  });

  factory ReservationDetail.fromJson(Map<String, dynamic> json) {
    return ReservationDetail(
      id: (json['id'] as num).toInt(),
      screeningId: (json['screening_id'] as num).toInt(),
      seatId: (json['seat_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      status: json['status']?.toString() ?? 'held',
      expiresAt: DateTime.parse(json['expires_at'].toString()),
    );
  }
}

class ExtendReservationResponse {
  final int id;
  final DateTime? expiresAt;

  ExtendReservationResponse({
    required this.id,
    required this.expiresAt,
  });

  factory ExtendReservationResponse.fromJson(Map<String, dynamic> json) {
    return ExtendReservationResponse(
      id: (json['id'] as num).toInt(),
      expiresAt:
          json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
    );
  }
}

class CancelReservationResponse {
  final String message;

  CancelReservationResponse({required this.message});

  factory CancelReservationResponse.fromJson(Map<String, dynamic> json) {
    return CancelReservationResponse(
      message: json['message']?.toString() ?? '',
    );
  }
}

class TicketDetail {
  final int id;
  final int screeningId;
  final int seatId;
  final String status;

  TicketDetail({
    required this.id,
    required this.screeningId,
    required this.seatId,
    required this.status,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    return TicketDetail(
      id: (json['id'] as num).toInt(),
      screeningId: (json['screening_id'] as num).toInt(),
      seatId: (json['seat_id'] as num).toInt(),
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

class BookFromReservationResponse {
  final List<TicketDetail> tickets;

  BookFromReservationResponse({required this.tickets});

  factory BookFromReservationResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['tickets'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(TicketDetail.fromJson)
        .toList();
    return BookFromReservationResponse(tickets: list);
  }
}

/// Repository wrapping the /seat-reservations and related endpoints.
class SeatReservationRepository {
  SeatReservationRepository();

  String get _baseUrl => ApiConfig.baseUrl;

  String get _seatApi => '$_baseUrl/seat-reservations';

  Map<String, String> _headers(String? token, {bool jsonBody = true}) {
    final headers = <String, String>{};
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// GET /seat-reservations/screening/{screening_id}/availability/me
  Future<SeatAvailabilityResponse> getSeatAvailabilityForUser({
    required int screeningId,
    String? token,
  }) async {
    final uri =
        Uri.parse('$_seatApi/screening/$screeningId/availability/me');
    final response = await http.get(uri, headers: _headers(token, jsonBody: false));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load seat availability: ${response.statusCode} ${response.body}',
      );
    }

    final body = jsonDecode(response.body);

    // Backend may return an array or wrapped object; normalize to SeatAvailabilityResponse.
    if (body is List) {
      final seats = body
          .map((e) => SeatWithStatus.fromJson(e as Map<String, dynamic>))
          .toList();
      return SeatAvailabilityResponse(screeningId: screeningId, seats: seats);
    } else if (body is Map<String, dynamic>) {
      final seatsJson = (body['seats'] as List<dynamic>? ?? <dynamic>[]);
      final seats = seatsJson
          .map((e) => SeatWithStatus.fromJson(e as Map<String, dynamic>))
          .toList();
      final id = (body['screening_id'] ?? screeningId) as int;
      return SeatAvailabilityResponse(screeningId: id, seats: seats);
    } else {
      throw Exception('Unexpected seat availability response format');
    }
  }

  /// POST /seat-reservations/toggle
  Future<ToggleSeatResponse> toggleSeatReservation({
    required int screeningId,
    required int seatId,
    String? token,
  }) async {
    final uri = Uri.parse('$_seatApi/toggle');
    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(<String, dynamic>{
        'screening_id': screeningId,
        'seat_id': seatId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle seat: ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ToggleSeatResponse.fromJson(body);
  }

  /// POST /seat-reservations/extend
  Future<ExtendReservationResponse> extendReservation({
    required List<int> reservationIds,
    required int extraMinutes,
    String? token,
  }) async {
    final uri = Uri.parse('$_seatApi/extend');
    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(<String, dynamic>{
        'reservation_ids': reservationIds,
        'extra_minutes': extraMinutes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to extend reservation: ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ExtendReservationResponse.fromJson(body);
  }

  /// DELETE /seat-reservations/cancel/{screening_id}
  Future<CancelReservationResponse> cancelReservation({
    required int screeningId,
    String? token,
  }) async {
    final uri = Uri.parse('$_seatApi/cancel/$screeningId');
    final response = await http.delete(
      uri,
      headers: _headers(token, jsonBody: false),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel reservation: ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return CancelReservationResponse.fromJson(body);
  }

  /// POST /tickets/book-from-reservation
  Future<BookFromReservationResponse> bookFromReservation({
    required List<int> reservationIds,
    required String paymentId,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl/tickets/book-from-reservation');
    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(<String, dynamic>{
        'reservation_ids': reservationIds,
        'payment_id': paymentId,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to book from reservation: ${response.statusCode} ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return BookFromReservationResponse.fromJson(body);
  }
}

