class Showtime {
  final int id;
  final int movieId;
  final int roomId;
  final DateTime screeningTime;
  final double price;

  Showtime({
    required this.id,
    required this.movieId,
    required this.roomId,
    required this.screeningTime,
    required this.price,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(
      id: (json['id'] as num).toInt(),
      movieId: (json['movie_id'] as num).toInt(),
      roomId: (json['room_id'] as num).toInt(),
      screeningTime: DateTime.parse(json['screening_time'].toString()),
      price: (json['price'] as num).toDouble(),
    );
  }
}

