import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
import '../services/app_state.dart';
import 'ticket_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _tabIndex = 0; // 0 upcoming, 1 past

  // Mock booking data
  final List<Map<String, dynamic>> _mockUpcoming = [
    {
      'id': '1',
      'movieTitle': 'Dune: Part Two',
      'genre': 'Sci-Fi',
      'duration': '2h 46m',
      'dateTime': 'Today, 19:30',
      'cinema': 'CineWay IMAX, Hall 4',
      'seats': 'F12, F13',
      'posterUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBULZ3LdqB6oEn_KmAgpjihrkHviSuwW_kSza6oXRaSKo2J7cZDUgDVAAsiVTZ33wGtKnJosT_YnAIF7olMCf52RLZRO4fSmp7Ilua3oBeWTHD7DakPmXYv2kxlJaWEJa5s8bnQNY9LWdkv-Vp9faYrdy61qw1OQKzGj5QFmoHR8TBjaVacpvnwW3fzcOT8LQc8zLpSGCgMHxg_nM36vaeSuIwPxg6QnuLR1-AjvkAWAIZUGxz0f19efBlvDqMigH0Qmq6SEjVNt4M',
      'isPast': false,
    },
    {
      'id': '2',
      'movieTitle': 'Cyber War 2077',
      'genre': 'Action',
      'duration': '2h 15m',
      'dateTime': 'Fri, 24 Oct • 21:00',
      'cinema': 'CineWay Downtown',
      'seats': 'H04, H05, H06',
      'posterUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuByWDGGxTKlD6ZFqFXERbzABFDabFK9kSDtF-clLZyMFBl76AuuZwnCu0D1Oo8EXaS_qzCh59bdRXRXLhQdj5CsZjzvY_AesUuImOoOIGWQv5PARLW57Qkx4zNRW4mHKPkJGrGInHqesfinreS1X2JSUiqwXYDz2mv2D6r6XRXYQiItLm1JgPjzxkoyHoujhS3mE1wfIH7rLHwobUQjfoDnUktNIMO9bU2_qM8L6PeVZ_Vga7QMZbrESfY2zyZyXU4EVkWPX-D-jAU',
      'isPast': false,
    },
  ];

  final List<Map<String, dynamic>> _mockPast = [
    {
      'id': '3',
      'movieTitle': 'Inception',
      'genre': 'Sci-Fi',
      'duration': '2h 28m',
      'dateTime': 'Sun, 15 Oct • 18:00',
      'cinema': 'CineWay Central',
      'seats': 'D05, D06',
      'posterUrl': 'https://via.placeholder.com/96x144?text=Inception',
      'isPast': true,
    },
  ];

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2127),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B4754), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tabIndex == 0 ? AppColors.dodgerBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Upcoming',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _tabIndex == 0 ? Colors.white : const Color(0xFF9CABBA),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tabIndex == 1 ? AppColors.dodgerBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Past',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _tabIndex == 1 ? Colors.white : const Color(0xFF9CABBA),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> booking, bool isUpcoming) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2127),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B4754), width: 1),
      ),
      child: Column(
        children: [
          // Movie info section with poster
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 96,
                    height: 144,
                    color: const Color(0xFF0F1419),
                    child: Image.network(
                      booking['posterUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.movie, size: 48, color: Color(0xFF5A6C7D)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title, genre, duration, date, location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['movieTitle'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking['genre']} • ${booking['duration']}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CABBA)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: AppColors.dodgerBlue),
                          const SizedBox(width: 8),
                          Text(
                            booking['dateTime'],
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18, color: AppColors.dodgerBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking['cinema'],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Dashed divider with half-circles (ticket tear-off effect)
          Stack(
            children: [
              // Dashed line
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CustomPaint(
                  painter: DashedLinePainter(color: const Color(0xFF3B4754)),
                  size: Size(MediaQuery.of(context).size.width, 2),
                ),
              ),
              // Left circle (half outside, half inside)
              Positioned(
                left: -12,
                top: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF101922),
                    border: Border.all(color: const Color(0xFF3B4754), width: 2),
                  ),
                ),
              ),
              // Right circle (half outside, half inside)
              Positioned(
                right: -12,
                top: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF101922),
                    border: Border.all(color: const Color(0xFF3B4754), width: 2),
                  ),
                ),
              ),
            ],
          ),
          // Seats and action button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEATS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9CABBA).withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['seats'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (isUpcoming)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TicketDetailsScreen(ticket: booking)),
                    ),
                    icon: const Icon(Icons.qr_code_2, size: 20),
                    label: const Text('View Ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dodgerBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TicketDetailsScreen(ticket: booking)),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dodgerBlue,
                      side: BorderSide(color: AppColors.dodgerBlue.withOpacity(0.3), width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _tabIndex == 0 ? _mockUpcoming : _mockPast;
    final isEmpty = data.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922).withOpacity(0.8),
        elevation: 0,
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking history')),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 64,
                          color: const Color(0xFF3B4754).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "You're all caught up!",
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF9CABBA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: data.length,
                    itemBuilder: (context, index) => _buildTicketCard(data[index], _tabIndex == 0),
                  ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    double startX = 0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => false;
}
