import 'package:flutter/material.dart';
import '../core/colors.dart';
import 'ticket_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _tabIndex = 0; // 0 upcoming, 1 past
  final List<Map<String, dynamic>> _staticUpcoming = [
    {
      'posterUrl': 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      'movieTitle': 'Inception',
      'genre': 'Sci‑Fi',
      'duration': '2h 28m',
      'dateTime': '2026-02-05 • 7:30 PM',
      'cinema': 'Mega Cinema Tunis',
      'seats': 'A2',
    },
    {
      'posterUrl': 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
      'movieTitle': 'The Matrix',
      'genre': 'Sci‑Fi',
      'duration': '2h 16m',
      'dateTime': '2026-02-08 • 9:00 PM',
      'cinema': 'Pathé Palace',
      'seats': 'C4, C5',
    },
  ];
  final List<Map<String, dynamic>> _staticPast = [
    {
      'posterUrl': 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      'movieTitle': 'The Dark Knight',
      'genre': 'Action',
      'duration': '2h 32m',
      'dateTime': '2026-01-20 • 5:00 PM',
      'cinema': 'Ciné Carthage',
      'seats': 'B7',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 96,
                    height: 144,
                    color: const Color(0xFF0F1419),
                    child: (booking['posterUrl']?.toString().isNotEmpty == true)
                        ? Image.network(
                      booking['posterUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.movie, size: 48, color: Color(0xFF5A6C7D)),
                      ),
                    )
                        : const Center(
                      child: Icon(Icons.movie, size: 48, color: Color(0xFF5A6C7D)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                        booking['genre'],
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['seats'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
    final data = _tabIndex == 0 ? _staticUpcoming : _staticPast;
    final isEmpty = data.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922),
        elevation: 0,
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
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
                          _tabIndex == 0
                              ? "No upcoming bookings"
                              : "No past bookings",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF9CABBA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final booking = data[index];
                      return _buildTicketCard(booking, _tabIndex == 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
