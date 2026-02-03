class Ticket {
  final int id;
  final int userId;
  final int screeningId;
  final int seatId;
  final double price;
  final String status; // pending, confirmed, cancelled
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
      id: json['id'] as int,
      userId: json['user_id'] as int,
      screeningId: json['screening_id'] as int,
      seatId: json['seat_id'] as int,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      bookedAt: DateTime.parse(json['booked_at'] as String),
      confirmedAt: json['confirmed_at'] != null 
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'screening_id': screeningId,
      'seat_id': seatId,
      'price': price,
      'status': status,
      'booked_at': bookedAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
    };
  }
}
