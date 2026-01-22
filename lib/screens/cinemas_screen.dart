import 'package:flutter/material.dart';
import 'cinema_details_screen.dart';
import '../repository/cinema_repository.dart';
import '../models/cinema.dart';

class CinemasScreen extends StatefulWidget {
  const CinemasScreen({super.key});

  @override
  State<CinemasScreen> createState() => _CinemasScreenState();
}

class _CinemasScreenState extends State<CinemasScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Nearby', 'Favorites', 'Format', 'Date'];

  final _repo = CinemaRepository();
  bool _loading = true;
  String? _error;
  List<Cinema> _cinemas = [];

  @override
  void initState() {
    super.initState();
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getAllCinemas();
      setState(() => _cinemas = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.95),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.near_me,
                      color: Color(0xFF4FC3F7),
                      size: 20,
                    ),
                  ),
                  const Text(
                    'Cinemas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: Color(0xFFF5F5F5),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Filters Section (search removed)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedFilterIndex;
                    final isDropdown = _filters[index] == 'Nearby' || _filters[index] == 'Format';

                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < _filters.length - 1 ? 12 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4FC3F7)
                              : const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4FC3F7).withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _filters[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFB0B0B0),
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            if (isDropdown) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.expand_more,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFB0B0B0),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Cinema List
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadCinemas,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _cinemas.isEmpty
                          ? const Center(
                              child: Text(
                                'No cinemas available',
                                style: TextStyle(color: Color(0xFFB0B0B0)),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _cinemas.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final cinema = _cinemas[index];
                                return _buildCinemaCard(
                                  icon: Icons.theaters_outlined,
                                  name: cinema.name,
                                  address: cinema.address.isNotEmpty ? cinema.address : cinema.city,
                                  distance: cinema.city.isNotEmpty ? cinema.city : '—',
                                  isNearby: false,
                                  features: cinema.amenities.isNotEmpty
                                      ? cinema.amenities
                                      : ['Accessible'],
                                  isFavorite: false,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CinemaDetailsScreen(cinemaId: cinema.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCinemaCard({
    required IconData icon,
    required String name,
    required String address,
    required String distance,
    required bool isNearby,
    required List<String> features,
    required bool isFavorite,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4FC3F7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNearby
                      ? const Color(0xFF4FC3F7).withOpacity(0.1)
                      : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: isNearby
                          ? const Color(0xFF4FC3F7)
                          : const Color(0xFFB0B0B0),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: TextStyle(
                        color: isNearby
                            ? const Color(0xFF4FC3F7)
                            : const Color(0xFFB0B0B0),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: features.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Color(0xFFC0C0C0),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite
                    ? const Color(0xFF4FC3F7)
                    : const Color(0xFFB0B0B0),
                size: 22,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
