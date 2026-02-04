import 'package:flutter/foundation.dart';

import '../../models/booking_summary.dart';
import '../../models/movie.dart';
import '../../models/seat.dart';
import '../../models/ticket.dart';
import '../../models/showtime.dart';
import '../../repository/movie_repository.dart';
import '../../repository/seat_repository.dart';
import '../../repository/showtime_api_repository.dart';
import '../../repository/ticket_repository.dart';
import '../session/session_viewmodel.dart';

class BookingsSummaryViewModel extends ChangeNotifier {
  final SessionViewModel _session;
  final TicketRepository _ticketRepo;
  final ShowtimeApiRepository _showtimeRepo;
  final SeatRepository _seatRepo;
  final MovieRepository _movieRepo;

  BookingsSummaryViewModel({
    required SessionViewModel session,
    required TicketRepository ticketRepo,
    required ShowtimeApiRepository showtimeRepo,
    required SeatRepository seatRepo,
    required MovieRepository movieRepo,
  })  : _session = session,
        _ticketRepo = ticketRepo,
        _showtimeRepo = showtimeRepo,
        _seatRepo = seatRepo,
        _movieRepo = movieRepo;

  bool _loading = false;
  String? _error;
  List<BookingSummary> _items = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<BookingSummary> get items => _items;

  // Simple in-memory caches to avoid repeated calls.
  final Map<int, Showtime> _showtimeCache = {};
  final Map<int, Movie> _movieCache = {};
  final Map<int, Map<int, Seat>> _roomSeatsCache = {}; // roomId -> (seatId -> Seat)
  final Map<int, String> _roomNameCache = {}; // screeningId -> roomName

  Future<void> load() async {
    final token = _session.accessToken;
    if (token == null || token.isEmpty) {
      _error = 'You must be signed in to view your bookings.';
      _items = const [];
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final tickets = await _ticketRepo.getMyTickets(token);
      _items = await _buildSummaries(tickets);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _items = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<BookingSummary>> _buildSummaries(List<Ticket> tickets) async {
    final byScreening = <int, List<Ticket>>{};
    for (final t in tickets) {
      byScreening.putIfAbsent(t.screeningId, () => <Ticket>[]).add(t);
    }

    final results = <BookingSummary>[];

    for (final entry in byScreening.entries) {
      final screeningId = entry.key;
      final group = entry.value;

      // Resolve showtime (screening) info: movieId, roomId, time
      final showtime = _showtimeCache[screeningId] ?? await _showtimeRepo.getShowtime(screeningId);
      _showtimeCache[screeningId] = showtime;

      // Resolve movie title
      final movie = _movieCache[showtime.movieId] ?? await _movieRepo.getMovieById(showtime.movieId);
      _movieCache[showtime.movieId] = movie;

      // Resolve seat labels (seat_id -> row/number) by loading room seats once.
      final roomId = showtime.roomId;
      Map<int, Seat> seatMap;
      if (_roomSeatsCache.containsKey(roomId)) {
        seatMap = _roomSeatsCache[roomId]!;
      } else {
        final seats = await _seatRepo.listRoomSeats(roomId);
        seatMap = {for (final s in seats) s.id: s};
        _roomSeatsCache[roomId] = seatMap;
      }

      final seatLabels = group
          .map((t) => seatMap[t.seatId]?.label ?? 'Seat ${t.seatId}')
          .toSet()
          .toList()
        ..sort((a, b) {
          // Sort like A1, A2, B1...
          final ra = a.isNotEmpty ? a.codeUnitAt(0) : 0;
          final rb = b.isNotEmpty ? b.codeUnitAt(0) : 0;
          if (ra != rb) return ra.compareTo(rb);
          final na = int.tryParse(a.substring(1)) ?? 0;
          final nb = int.tryParse(b.substring(1)) ?? 0;
          return na.compareTo(nb);
        });

      // Best-effort room name: backend "enhanced" endpoint gives room_name (no room_id),
      // so we keep a fallback if not available.
      final roomName = _roomNameCache[screeningId] ?? 'Room ${showtime.roomId}';
      final status = _aggregateStatus(group);

      results.add(
        BookingSummary(
          screeningId: screeningId,
          movieTitle: movie.title,
          posterUrl: movie.bannerUrl,
          screeningTime: showtime.screeningTime,
          roomName: roomName,
          seats: seatLabels,
          status: status,
        ),
      );
    }

    results.sort((a, b) => b.screeningTime.compareTo(a.screeningTime));
    return results;
  }

  String _aggregateStatus(List<Ticket> group) {
    // If any pending -> pending, else if any cancelled -> cancelled, else confirmed.
    final statuses = group.map((t) => t.status).toSet();
    if (statuses.contains('pending')) return 'pending';
    if (statuses.contains('cancelled')) return 'cancelled';
    if (statuses.contains('confirmed')) return 'confirmed';
    return statuses.isNotEmpty ? statuses.first : 'pending';
  }
}

