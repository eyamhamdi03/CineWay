import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../data/mock_movies.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _tabIndex = 0; // 0 upcoming, 1 history

  final List<Map<String, dynamic>> _upcoming = [
    {
      'movie': mockMovies[0],
      'rating': 'PG-13',
      'time': 'Today, 7:30 PM',
      'cinema': 'CineWay Grand Hall',
      'seats': 'G7, G8'
    },
    {
      'movie': mockMovies.length > 0 ? mockMovies[0] : null,
      'rating': 'PG-13',
      'time': 'Tomorrow, 5:00 PM',
      'cinema': 'CineWay Plex',
      'seats': 'D12'
    }
  ];

  final List<Map<String, dynamic>> _history = [
    {
      'movie': mockMovies.length > 0 ? mockMovies[0] : null,
      'rating': 'PG-13',
      'time': 'Aug 01, 8:00 PM',
      'cinema': 'CineWay Downtown',
      'seats': 'B4, B5'
    }
  ];

  Widget _buildTabHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _tabIndex = 0),
          child: Column(
            children: [
              Text('Upcoming', style: TextStyle(color: _tabIndex == 0 ? AppColors.dodgerBlue : Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(height: 3, width: 80, decoration: BoxDecoration(color: _tabIndex == 0 ? AppColors.dodgerBlue : Colors.transparent, borderRadius: BorderRadius.circular(2)))
            ],
          ),
        ),
        const SizedBox(width: 28),
        GestureDetector(
          onTap: () => setState(() => _tabIndex = 1),
          child: Column(
            children: [
              Text('History', style: TextStyle(color: _tabIndex == 1 ? AppColors.dodgerBlue : Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(height: 3, width: 80, decoration: BoxDecoration(color: _tabIndex == 1 ? AppColors.dodgerBlue : Colors.transparent, borderRadius: BorderRadius.circular(2)))
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookingCard(Map<String, dynamic> b) {
    final movie = b['movie'];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF172026), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 110,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFF101420)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie != null && movie.bannerUrl.isNotEmpty ? Image.asset(movie.bannerUrl, fit: BoxFit.cover) : const Icon(Icons.movie, size: 48, color: AppColors.jumbo),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie != null ? movie.title : 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(b['rating'], style: const TextStyle(color: AppColors.jumbo)),
                const SizedBox(height: 6),
                Text(b['time'], style: const TextStyle(color: AppColors.jumbo)),
                const SizedBox(height: 6),
                Text(b['cinema'], style: const TextStyle(color: AppColors.jumbo)),
                const SizedBox(height: 6),
                Text('Seats: ${b['seats']}', style: const TextStyle(color: AppColors.jumbo)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.dodgerBlue.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.qr_code, color: AppColors.dodgerBlue),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Show QR (demo)'))),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _tabIndex == 0 ? _upcoming : _history;
    return Scaffold(
      backgroundColor: AppColors.mirage,
      appBar: AppBar(
        backgroundColor: AppColors.mirage,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        centerTitle: true,
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildTabHeader(),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFF1F2933)),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                itemCount: data.length,
                itemBuilder: (context, index) => _bookingCard(data[index]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
