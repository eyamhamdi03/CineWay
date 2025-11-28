import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../data/mock_movies.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final dynamic booking; // can be AppState.Booking or a Map

  const BookingConfirmationScreen({super.key, this.booking});

  String _generateBookingId() {
    return 'CW-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    final hasBooking = booking != null;
    final movieTitle = hasBooking
        ? (booking is Map ? (booking['movieTitle'] ?? '') : (booking.movieTitle ?? ''))
        : (mockMovies.isNotEmpty ? mockMovies[0].title : 'Movie');
    final dateTime = hasBooking ? (booking is Map ? (booking['dateTime'] ?? '') : booking.dateTime) : 'Sunday, 27 October • 7:30 PM';
    final cinema = hasBooking ? (booking is Map ? (booking['cinema'] ?? '') : booking.cinema) : 'CineWay Plex, Downtown • Screen 8';
    final seats = hasBooking ? (booking is Map ? (booking['seats'] ?? '') : booking.seats) : 'F7, F8 (2 Tickets)';
    final bookingId = hasBooking ? (booking is Map ? (booking['id'] ?? _generateBookingId()) : booking.id) : _generateBookingId();

    return Scaffold(
      backgroundColor: AppColors.mirage,
      appBar: AppBar(
        backgroundColor: AppColors.mirage,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        centerTitle: true,
        title: const Text('Your Ticket', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFF1A2228), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    const Text('Booking Confirmed!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('Scan the QR code below for entry.', style: TextStyle(color: AppColors.jumbo)),
                    const SizedBox(height: 16),

                    // QR / booking id box (placeholder)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        color: const Color(0xFF2E484E),
                        child: Center(child: Text(bookingId, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text('Booking ID: $bookingId', style: const TextStyle(color: AppColors.jumbo)),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              // Movie row (title + meta)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF141A20), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFF101420)),
                      child: const Center(child: Icon(Icons.movie, color: AppColors.jumbo)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(movieTitle, style: const TextStyle(color: AppColors.dodgerBlue, fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text('• • •', style: const TextStyle(color: AppColors.jumbo)),
                      ]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Details card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF141A20), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [Icon(Icons.calendar_today_outlined, color: AppColors.dodgerBlue), SizedBox(width: 10), Text('Date & Time', style: TextStyle(color: AppColors.jumbo))]),
                    const SizedBox(height: 8),
                    Text(dateTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(children: const [Icon(Icons.theaters, color: AppColors.dodgerBlue), SizedBox(width: 10), Text('Cinema & Screen', style: TextStyle(color: AppColors.jumbo))]),
                    const SizedBox(height: 8),
                    Text(cinema, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(children: const [Icon(Icons.event_seat, color: AppColors.dodgerBlue), SizedBox(width: 10), Text('Seats', style: TextStyle(color: AppColors.jumbo))]),
                    const SizedBox(height: 8),
                    Text(seats, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // demo: add to calendar
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to calendar (demo)')));
                  },
                  icon: const Icon(Icons.calendar_today, color: Colors.black),
                  label: const Text('Add to Calendar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.dodgerBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('View receipt (demo)')));
                  },
                  icon: const Icon(Icons.receipt_long, color: AppColors.dodgerBlue),
                  label: const Text('View Receipt', style: TextStyle(color: AppColors.dodgerBlue, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A3942)), backgroundColor: const Color(0xFF141A20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          // go to bookings
                          Navigator.pushNamed(context, '/bookings');
                        },
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A3942)), backgroundColor: const Color(0xFF141A20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('View My Bookings', style: TextStyle(color: AppColors.jumbo, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // go to home
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.dodgerBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Back to Home', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
