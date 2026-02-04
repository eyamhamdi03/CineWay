// Seat Status Enum
enum SeatStatus {
  available,
  held,
  booked,
  reservedByMe,
}

SeatStatus seatStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'available':
      return SeatStatus.available;
    case 'held':
      return SeatStatus.held;
    case 'booked':
      return SeatStatus.booked;
    case 'reserved_by_me':
      return SeatStatus.reservedByMe;
    default:
      return SeatStatus.available;
  }
}

// Seat with Status Model
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
    return SeatWithStatus(
      seatId: json['seat_id'] ?? 0,
      status: seatStatusFromString(json['status'] ?? 'available'),
      heldByUser: json['held_by_user'],
      reservedBy: json['reserved_by'],
      isMine: json['is_mine'] ?? false,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      rowLabel: json['row_label'],
      seatNumber: json['seat_number'],
      seatType: json['seat_type'],
    );
  }
}

// Seat Availability Response
class SeatAvailabilityResponse {
  final List<SeatWithStatus> seats;

  SeatAvailabilityResponse({required this.seats});

  factory SeatAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return SeatAvailabilityResponse(
      seats: (json['seats'] as List? ?? [])
          .map((s) => SeatWithStatus.fromJson(s))
          .toList(),
    );
  }
}

// Seat Reservation Model
class SeatReservation {
  final int id;
  final int userId;
  final int seatId;
  final int screeningId;
  final DateTime createdAt;
  final DateTime expiresAt;

  SeatReservation({
    required this.id,
    required this.userId,
    required this.seatId,
    required this.screeningId,
    required this.createdAt,
    required this.expiresAt,
  });

  factory SeatReservation.fromJson(Map<String, dynamic> json) {
    return SeatReservation(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      seatId: json['seat_id'] ?? 0,
      screeningId: json['screening_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(json['expires_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Toggle Seat Reservation Response
class Reservation {
  final int id;
  final DateTime expiresAt;

  Reservation({required this.id, required this.expiresAt});

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : DateTime.now().add(const Duration(minutes: 5)),
    );
  }
}

class ToggleSeatReservationResponse {
  final String action;
  final List<int> seatIds;
  final int? expiresInMinutes;
  final Reservation? reservation;

  ToggleSeatReservationResponse({
    required this.action,
    required this.seatIds,
    this.expiresInMinutes,
    this.reservation,
  });

  factory ToggleSeatReservationResponse.fromJson(Map<String, dynamic> json) {
    return ToggleSeatReservationResponse(
      action: json['action'] ?? 'unknown',
      seatIds: (json['seat_ids'] as List? ?? []).cast<int>(),
      expiresInMinutes: json['expires_in_minutes'],
      reservation: json['reservation'] != null
          ? Reservation.fromJson(json['reservation'])
          : null,
    );
  }
}
