class Seat {
  final int id;
  final int roomId;
  final String rowLabel;
  final int seatNumber;
  final String seatType;

  Seat({
    required this.id,
    required this.roomId,
    required this.rowLabel,
    required this.seatNumber,
    required this.seatType,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: (json['id'] as num).toInt(),
      roomId: (json['room_id'] as num).toInt(),
      rowLabel: (json['row_label'] ?? '').toString(),
      seatNumber: (json['seat_number'] as num).toInt(),
      seatType: (json['seat_type'] ?? 'standard').toString(),
    );
  }

  String get label => '$rowLabel$seatNumber';
}

