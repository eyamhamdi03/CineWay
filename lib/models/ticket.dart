class Ticket {
  final int id;
  final int userId;
  final int screeningId;
  final int seatId;
  final double price;
  final String status; // pending | confirmed | cancelled
  final DateTime bookedAt;
  final DateTime? confirmedAt;

  Ticket({
    required this.id,
    required this.userId,
    required this.screeningId,
    required this.seatId,
    required this.price,
    required this.status,
    required this.bookedAt,
    this.confirmedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      screeningId: (json['screening_id'] as num).toInt(),
      seatId: (json['seat_id'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      status: (json['status'] ?? 'pending').toString(),
      bookedAt: DateTime.parse(json['booked_at'].toString()),
      confirmedAt:
          json['confirmed_at'] != null ? DateTime.tryParse(json['confirmed_at'].toString()) : null,
    );
  }
}

