class Ticket {
	final int id;
	final int userId;
	final int screeningId;
	final int seatId;
	final double price;
	final String status;
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
			id: json['id'] ?? 0,
			userId: json['user_id'] ?? 0,
			screeningId: json['screening_id'] ?? 0,
			seatId: json['seat_id'] ?? 0,
			price: (json['price'] as num?)?.toDouble() ?? 0.0,
			status: json['status'] ?? 'pending',
			bookedAt: DateTime.tryParse(json['booked_at'] ?? '') ?? DateTime.now(),
			confirmedAt: json['confirmed_at'] != null
					? DateTime.tryParse(json['confirmed_at'])
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
