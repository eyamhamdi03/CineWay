import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/mock_movies.dart';
import '../repository/seat_reservation_repository.dart';
import '../services/screening_websocket_service.dart';
import '../viewmodel/session/session_viewmodel.dart';
import 'payment_screen.dart';

class SelectSeatsScreen extends StatefulWidget {
  final String? movieTitle;
  final String? cinema;
  final String? dateTime;

  /// Backend screening/showtime id (required to talk to the API).
  final int showtimeId;

  /// Max number of seats user can select (ticket count).
  final int ticketCount;

  const SelectSeatsScreen({
    super.key,
    this.movieTitle,
    this.cinema,
    this.dateTime,
    required this.showtimeId,
    this.ticketCount = 3, // Default max seats is now 3
  });

  @override
  State<SelectSeatsScreen> createState() => _SelectSeatsScreenState();
}

class _SelectSeatsScreenState extends State<SelectSeatsScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, List<int>> _seatsByRow = {};
  final Map<String, SeatWithStatus> _seatStatuses = {};
  final Set<String> _selected = <String>{};
  double _seatPrice = 12.00;

  DateTime? _holdExpiresAt;
  int _timeRemainingSeconds = 0;
  List<int> _reservationIds = <int>[];

  String? _errorMessage;
  bool _isProcessing = false;

  final SeatReservationRepository _seatRepo = SeatReservationRepository();
  final ScreeningWebSocketService _wsService = ScreeningWebSocketService();

  StreamSubscription<SeatUpdateEvent>? _wsSub;
  StreamSubscription<WebSocketConnectionStatus>? _wsStatusSub;

  AnimationController? _glowController;
  Animation<double>? _glow;
  Timer? _countdownTimer;
  bool _isNavigatingToPayment = false;

  String _seatKey(String row, int num) => '$row$num';

  SeatWithStatus? _statusForSeat(String key) => _seatStatuses[key];

  SeatStatus _effectiveStatus(String key) {
    final s = _statusForSeat(key);
    if (s == null) return SeatStatus.available;
    if (s.status == SeatStatus.reservedByMe || s.isMine) {
      return SeatStatus.reservedByMe;
    }
    return s.status;
  }

  bool _isAvailable(String key) {
    final eff = _effectiveStatus(key);
    return eff == SeatStatus.available || eff == SeatStatus.reservedByMe;
  }

  bool _isReservedByMe(String key) {
    final s = _statusForSeat(key);
    return s?.isMine == true || s?.status == SeatStatus.reservedByMe;
  }

  Future<void> _toggleSeat(String seatKey) async {
    if (!_isAvailable(seatKey) && !_isReservedByMe(seatKey)) {
      final status = _effectiveStatus(seatKey);
      if (status == SeatStatus.held) {
        _showSnack('Seat is reserved by another user');
      } else if (status == SeatStatus.booked) {
        _showSnack('Seat is already booked');
      }
      return;
    }

    if (_isProcessing) return;

    final isSelected = _selected.contains(seatKey);

    // Enforce maximum 3 seats
    if (!isSelected && _selected.length >= widget.ticketCount) {
      _showSnack('You can only select ${widget.ticketCount} seats');
      return;
    }

    final session = context.read<SessionViewModel>();
    final token = session.accessToken;
    if (token == null || token.isEmpty) {
      _showSnack('You must be signed in to reserve seats');
      return;
    }

    final rowLabel = seatKey.substring(0, 1);
    final seatNumber = int.tryParse(seatKey.substring(1));
    if (seatNumber == null) return;
    final seatId = _statusForSeat(seatKey)?.seatId;
    if (seatId == null || seatId == 0) {
      _showSnack('Seat data not loaded yet. Please wait a second and try again.');
      return;
    }

    _isProcessing = true;
    _errorMessage = null;
    setState(() {});

    try {
      final response = await _seatRepo.toggleSeatReservation(
        screeningId: widget.showtimeId,
        seatId: seatId,
        token: token,
      );

      if (response.action == 'reserved') {
        _selected.add(seatKey);
        DateTime? expiresAt;
        if (response.reservation != null) {
          expiresAt = response.reservation!.expiresAt;
          final current = List<int>.from(_reservationIds);
          if (!current.contains(response.reservation!.id)) {
            current.add(response.reservation!.id);
          }
          _reservationIds = current;
        } else if (response.expiresInMinutes != null) {
          expiresAt = DateTime.now().add(Duration(minutes: response.expiresInMinutes!));
        }
        _holdExpiresAt = expiresAt ?? _holdExpiresAt;

        final old = _statusForSeat(seatKey);
        if (old != null) {
          _seatStatuses[seatKey] = SeatWithStatus(
            seatId: old.seatId,
            status: SeatStatus.reservedByMe,
            heldByUser: old.heldByUser,
            reservedBy: old.reservedBy,
            isMine: true,
            expiresAt: expiresAt ?? old.expiresAt,
            rowLabel: old.rowLabel ?? rowLabel,
            seatNumber: old.seatNumber ?? seatNumber,
            seatType: old.seatType,
          );
        }
      } else if (response.action == 'unreserved') {
        _selected.remove(seatKey);
        _reservationIds.clear();

        final old = _statusForSeat(seatKey);
        if (old != null) {
          _seatStatuses[seatKey] = SeatWithStatus(
            seatId: old.seatId,
            status: SeatStatus.available,
            heldByUser: null,
            reservedBy: null,
            isMine: false,
            expiresAt: null,
            rowLabel: old.rowLabel ?? rowLabel,
            seatNumber: old.seatNumber ?? seatNumber,
            seatType: old.seatType,
          );
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      _showSnack(_errorMessage!);
    } finally {
      _isProcessing = false;
      setState(() {});
    }
  }

  List<String> _sortedSelected() {
    final list = _selected.toList();
    list.sort((a, b) {
      final ra = a.codeUnitAt(0);
      final rb = b.codeUnitAt(0);
      if (ra != rb) return ra.compareTo(rb);
      final ca = int.parse(a.substring(1));
      final cb = int.parse(b.substring(1));
      return ca.compareTo(cb);
    });
    return list;
  }

  void _proceed() {
    if (_selected.isEmpty) {
      _showSnack('Please select at least one seat');
      return;
    }
    final seats = _sortedSelected();
    final movieTitle =
        widget.movieTitle ?? (mockMovies.isNotEmpty ? mockMovies[0].title : 'Movie');
    final totalAmount = (_selected.length * _seatPrice).toDouble();
    final cinema = widget.cinema ?? 'CineWay Plex';
    final dateTime = widget.dateTime ?? 'Selected Showtime';

    _isNavigatingToPayment = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          movieTitle: movieTitle,
          cinema: cinema,
          dateTime: dateTime,
          seats: seats,
          amount: totalAmount,
          reservationIds: _reservationIds,
          screeningId: widget.showtimeId,
        ),
      ),
    );
  }

  Widget _buildSeat(String row, int number) {
    final id = _seatKey(row, number);
    final selected = _selected.contains(id);
    final status = _effectiveStatus(id);

    Color color;
    Icon? icon;
    if (status == SeatStatus.booked) {
      color = const Color(0xFF252525);
      icon = const Icon(Icons.lock, size: 12, color: Colors.white30);
    } else if (status == SeatStatus.held) {
      color = const Color(0xFF252525);
      icon = const Icon(Icons.event_seat, size: 12, color: Colors.white38);
    } else if (status == SeatStatus.reservedByMe) {
      color = const Color(0xFF00BFFF);
    } else {
      color = const Color(0xFF3A3A3C);
    }

    return GestureDetector(
      onTap: () => _toggleSeat(id),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: selected
              ? [
            BoxShadow(
              color: const Color(0xFF00BFFF).withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ]
              : null,
        ),
        child: icon,
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _glowController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glow = CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut);

    _loadAvailability();
    _setupWebSocket();
    _startCountdown();
  }

  @override
  void dispose() {
    if (!_isNavigatingToPayment && _selected.isNotEmpty) {
      final session = context.read<SessionViewModel>();
      final token = session.accessToken;
      if (token != null && token.isNotEmpty) {
        _seatRepo.cancelReservation(screeningId: widget.showtimeId, token: token);
      }
    }
    _glowController?.dispose();
    _wsSub?.cancel();
    _wsStatusSub?.cancel();
    _wsService.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    try {
      final session = context.read<SessionViewModel>();
      final token = session.accessToken;

      final availability = await _seatRepo.getSeatAvailabilityForUser(
        screeningId: widget.showtimeId,
        token: token,
      );

      _seatsByRow.clear();
      _seatStatuses.clear();
      _selected.clear();

      for (final seat in availability.seats) {
        final row = seat.rowLabel ?? 'A';
        final number = seat.seatNumber ?? 1;
        final key = _seatKey(row, number);

        _seatsByRow.putIfAbsent(row, () => <int>[]);
        if (!_seatsByRow[row]!.contains(number)) {
          _seatsByRow[row]!.add(number);
        }

        _seatStatuses[key] = seat;

        if (seat.isMine || seat.status == SeatStatus.reservedByMe) {
          _selected.add(key);
        }
      }

      for (final row in _seatsByRow.keys) {
        _seatsByRow[row]!.sort();
      }
      setState(() {});
    } catch (e) {
      _errorMessage = 'Failed to load seat availability';
      _showSnack(_errorMessage!);
    }
  }

  void _setupWebSocket() {
    final session = context.read<SessionViewModel>();
    final token = session.accessToken;
    if (token == null || token.isEmpty) return;

    _wsService.connect(screeningId: widget.showtimeId, token: token);

    _wsStatusSub = _wsService.connectionStatusStream.listen((_) {});

    _wsSub = _wsService.seatUpdatesStream.listen((event) {
      final cached = _seatStatuses.values
          .where((s) => s.seatId == event.seatId)
          .cast<SeatWithStatus?>()
          .firstWhere((_) => true, orElse: () => null);
      final row = cached?.rowLabel;
      final number = cached?.seatNumber;
      if (row == null || number == null) {
        _loadAvailability();
        return;
      }
      final key = _seatKey(row, number);

      final old = _statusForSeat(key);
      final updated = SeatWithStatus(
        seatId: old?.seatId ?? event.seatId,
        status: event.status,
        heldByUser: event.userId,
        reservedBy: old?.reservedBy,
        isMine: event.isMine,
        expiresAt: event.expiresAt ?? old?.expiresAt,
        rowLabel: old?.rowLabel ?? row,
        seatNumber: old?.seatNumber ?? number,
        seatType: old?.seatType,
      );

      _seatStatuses[key] = updated;

      if (event.isMine) {
        if (event.status == SeatStatus.available) {
          _selected.remove(key);
        } else {
          _selected.add(key);
        }
      } else {
        if (event.status != SeatStatus.available) _selected.remove(key);
      }

      setState(() {});
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_holdExpiresAt == null) {
        if (_timeRemainingSeconds != 0) {
          setState(() => _timeRemainingSeconds = 0);
        }
        return;
      }
      final diff = _holdExpiresAt!.difference(DateTime.now());
      final secs = diff.inSeconds;
      if (secs <= 0) {
        final session = context.read<SessionViewModel>();
        final token = session.accessToken;
        if (token != null && token.isNotEmpty) {
          _seatRepo.cancelReservation(screeningId: widget.showtimeId, token: token);
        }
        _holdExpiresAt = null;
        _timeRemainingSeconds = 0;
        _selected.clear();
        _reservationIds.clear();
        setState(() {});
      } else {
        setState(() => _timeRemainingSeconds = secs);
      }
    });
  }

  String _formatTimeRemaining() {
    final s = _timeRemainingSeconds;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final movieTitle =
        widget.movieTitle ?? (mockMovies.isNotEmpty ? mockMovies[0].title : 'Movie');
    final selectedList = _sortedSelected();
    final total = (_selected.length * _seatPrice);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F).withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: const Text('Select Seats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(movieTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(widget.cinema ?? 'Selected Cinema',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93))),
                  const SizedBox(height: 4),
                  Text(widget.dateTime ?? 'Selected Showtime',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _glow ?? kAlwaysCompleteAnimation,
                    builder: (_, __) => CustomPaint(
                      painter: CinemaScreenPainter(glow: 0.6 + 0.4 * ((_glow?.value) ?? 1.0)),
                      size: const Size(double.infinity, 42),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('CINEMA SCREEN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 360),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _seatsByRow.entries.map((entry) {
                      final rowLabel = entry.key;
                      final numbers = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, child: Text(rowLabel, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)))),
                            const SizedBox(width: 10),
                            ...numbers.map((n) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2), child: _buildSeat(rowLabel, n))),
                            const SizedBox(width: 10),
                            SizedBox(width: 20, child: Text(rowLabel, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _legendItem('Your seat', const Color(0xFF00BFFF)),
                  _legendItem('Available', const Color(0xFF3A3A3C)),
                  _legendItem('Reserved', const Color(0xFF252525)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F).withOpacity(0.95),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Price', style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('\$ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${_selected.length} Tickets', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(selectedList.join(', '), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF00BFFF))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: const Text('Buy Tickets', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class CinemaScreenPainter extends CustomPainter {
  final double glow;
  CinemaScreenPainter({this.glow = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(10, size.height - 5)
      ..quadraticBezierTo(size.width / 2, 5, size.width - 10, size.height - 5);

    final glowPaint = Paint()
      ..color = const Color(0xFF00BFFF).withOpacity(0.25 * glow)
      ..strokeWidth = 14 + 3 * glow
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final linePaint = Paint()
      ..color = const Color(0xFF00BFFF)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CinemaScreenPainter oldDelegate) => oldDelegate.glow != glow;
}
