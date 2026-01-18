class Booking {
  final String id;
  final String movieTitle;
  final String dateTime;
  final String cinema;
  final String seats;

  Booking({
    required this.id,
    required this.movieTitle,
    required this.dateTime,
    required this.cinema,
    required this.seats,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'movieTitle': movieTitle,
    'dateTime': dateTime,
    'cinema': cinema,
    'seats': seats,
  };

  static Booking fromJson(Map<String, dynamic> j) => Booking(
    id: j['id'] ?? '',
    movieTitle: j['movieTitle'] ?? '',
    dateTime: j['dateTime'] ?? '',
    cinema: j['cinema'] ?? '',
    seats: j['seats'] ?? '',
  );
}
