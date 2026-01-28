import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
import 'ticket_details_screen.dart';
import '../viewmodel/bookings/bookings_summary_viewmodel.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _tabIndex = 0; // 0 upcoming, 1 past

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookingsSummaryViewModel>().load();
    });
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
    final vm = context.watch<BookingsSummaryViewModel>();
    final now = DateTime.now();

    final items = vm.items
        .where((b) {
      final isUpcoming = b.screeningTime.isAfter(now);
      return _tabIndex == 0 ? isUpcoming : !isUpcoming;
    })
        .toList()
      ..sort((a, b) {
        if (_tabIndex == 0) {
          return a.screeningTime.compareTo(b.screeningTime);
        } else {
          return b.screeningTime.compareTo(a.screeningTime);
        }
      });

    final data = items.map((b) {
      return {
        'id': b.screeningId.toString(),
        'movieTitle': b.movieTitle,
        'posterUrl': b.posterUrl,
        'genre': b.status,
        'dateTime': b.screeningTime.toLocal().toString(),
        'cinema': b.roomName,
        'seats': b.seats.join(', '),
        'screeningId': b.screeningId,
      };
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922),
        elevation: 0,
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) =>
                  _buildTicketCard(data[index], _tabIndex == 0),
            ),
          ),
        ],
      ),
    );
  }
}
