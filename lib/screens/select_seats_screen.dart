import 'package:flutter/material.dart';
import '../data/mock_movies.dart';
import 'payment_screen.dart';

class SelectSeatsScreen extends StatefulWidget {
  final String? movieTitle;
  final String? cinema;
  final String? dateTime;

  const SelectSeatsScreen({super.key, this.movieTitle, this.cinema, this.dateTime});

  @override
  State<SelectSeatsScreen> createState() => _SelectSeatsScreenState();
}

class _SelectSeatsScreenState extends State<SelectSeatsScreen> with SingleTickerProviderStateMixin {
  // Rows A - G
  final List<String> _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  final int _cols = 10;

  // occupied seats (sample)
  final Set<String> _occupied = {
    'G4', 'G5', 'F5', 'F6', 'E2', 'E3', 'D6', 'D7', 'C1', 'C2'
  };

  final Set<String> _selected = {'E4', 'E5', 'E6'};
  final double _seatPrice = 12.00;
  final int _maxSelectable = 6;

  AnimationController? _glowController;
  Animation<double>? _glow;


  String _seatKey(int r, int c) => '${_rows[r]}${c + 1}';

  void _toggleSeat(String seat) {
    if (_occupied.contains(seat)) return;
    setState(() {
      if (_selected.contains(seat)) _selected.remove(seat);
      else {
        if (_selected.length >= _maxSelectable) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum seats selected')));
          return;
        }
        _selected.add(seat);
      }
    });
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one seat')));
      return;
    }
    final seats = _sortedSelected();
    final movieTitle = widget.movieTitle ?? (mockMovies.isNotEmpty ? mockMovies[0].title : 'Movie');
    final totalAmount = (_selected.length * _seatPrice).toDouble();
    final cinema = widget.cinema ?? 'CineWay Plex';
    final dateTime = widget.dateTime ?? 'Today • 7:30 PM';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          movieTitle: movieTitle,
          cinema: cinema,
          dateTime: dateTime,
          seats: seats,
          amount: totalAmount,
        ),
      ),
    );
  }

  Widget _buildSeat(String id) {
    final selected = _selected.contains(id);
    final occupied = _occupied.contains(id);
    Color color;
    if (occupied) color = const Color(0xFF252525);
    else if (selected) color = const Color(0xFF00BFFF);
    else color = const Color(0xFF3A3A3C);

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
        child: occupied ? const Icon(Icons.lock, size: 12, color: Colors.white30) : null,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _glowController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glow = CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowController?.dispose();
    super.dispose();
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
                    children: List.generate(_rows.length, (r) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              child: Text(
                                _rows[r],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ...List.generate(_cols, (c) {
                              final id = _seatKey(r, c);
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                child: _buildSeat(id),
                              );
                            }),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 20,
                              child: Text(
                                _rows[r],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
