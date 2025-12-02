class Screening {
  final int id;
  final int movieId;
  final int roomId;
  final DateTime screeningTime;
  final double price;
  final DateTime createdAt;

  Screening({
    required this.id,
    required this.movieId,
    required this.roomId,
    required this.screeningTime,
    required this.price,
    required this.createdAt,
  });

  // ----------------------- FROM JSON -----------------------
  factory Screening.fromJson(Map<String, dynamic> json) {
    return Screening(
      id: json['id'],
      movieId: json['movie_id'],
      roomId: json['room_id'],
      screeningTime: DateTime.parse(json['screening_time']),
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // ----------------------- TO JSON ------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'room_id': roomId,
      'screening_time': screeningTime.toIso8601String(),
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
