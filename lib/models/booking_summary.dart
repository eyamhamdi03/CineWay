class BookingSummary {
  final int screeningId;
  final String movieTitle;
  final String posterUrl;
  final DateTime screeningTime;
  final String roomName;
  final List<String> seats; // e.g. ["A1", "A2"]
  final String status; // aggregated status (e.g. confirmed/pending)

  BookingSummary({
    required this.screeningId,
    required this.movieTitle,
    required this.posterUrl,
    required this.screeningTime,
    required this.roomName,
    required this.seats,
    required this.status,
  });
}

