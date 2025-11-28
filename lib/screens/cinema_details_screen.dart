import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../data/mock_movies.dart';

class CinemaDetailsScreen extends StatelessWidget {
  const CinemaDetailsScreen({super.key});

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _amenityTile(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFF141A20), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: const Color(0xFF213036), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.dodgerBlue),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mirage,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/cinema_banner.jpg'), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 14,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('CineWay Downtown', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                        SizedBox(height: 6),
                        Text('123 Movie Lane, Metropolis, 10001 • 1.2 miles away', style: TextStyle(color: AppColors.jumbo)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showSnack(context, 'Open maps (demo)'),
                        icon: const Icon(Icons.navigation, color: Colors.white),
                        label: const Text('Get Directions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.dodgerBlue, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showSnack(context, 'Call cinema (demo)'),
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text('Call Cinema', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A3942)), backgroundColor: const Color(0xFF141A20), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: const Text('Amenities', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: 160, child: _amenityTile(Icons.theaters, 'IMAX')),
                    SizedBox(width: 160, child: _amenityTile(Icons.speaker, 'Dolby Atmos')),
                    SizedBox(width: 160, child: _amenityTile(Icons.accessible, 'Accessible')),
                    SizedBox(width: 160, child: _amenityTile(Icons.local_parking, 'Parking')),
                    SizedBox(width: 160, child: _amenityTile(Icons.food_bank, 'Concessions')),
                    SizedBox(width: 160, child: _amenityTile(Icons.chair, 'Recliners')),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: const Text('Now Showing', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final m = mockMovies[index % mockMovies.length];
                    return SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 180,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFF141A20)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: m.bannerUrl.isNotEmpty ? Image.asset(m.bannerUrl, fit: BoxFit.cover) : const Icon(Icons.movie, size: 60, color: AppColors.jumbo),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(m.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(m.duration, style: const TextStyle(color: AppColors.jumbo)),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: mockMovies.length,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
