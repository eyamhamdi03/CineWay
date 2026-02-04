import 'package:flutter/material.dart';
import 'cinema_details_screen.dart';
import '../repository/cinema_repository.dart';
import '../models/cinema.dart';
import '../viewmodel/gps/gps_viewmodel.dart';

class CinemasScreen extends StatefulWidget {
  const CinemasScreen({super.key});

  @override
  State<CinemasScreen> createState() => _CinemasScreenState();
}

class _CinemasScreenState extends State<CinemasScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Nearby', 'Favorites', 'Format', 'Date'];

  final GPSViewModel _gps = GPSViewModel();
  final Set<int> _favoriteCinemaIds = {};
  String _selectedFormat = 'All';
  String _selectedDateSort = 'Newest';
  double? _nearbyRadiusKm = 10;

  final _repo = CinemaRepository();
  bool _loading = true;
  String? _error;
  List<Cinema> _cinemas = [];

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadCinemas();
  }

  Future<void> _loadLocation() async {
    await _gps.getLocation();
    if (mounted) {
      setState(() {});
    }
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

  String _filterLabel(int index) {
    final base = _filters[index];
    if (index == 0 && _selectedFilterIndex == 0 && _nearbyRadiusKm != null && _gps.userPosition != null) {
      return '$base ${_nearbyRadiusKm!.toStringAsFixed(0)}km';
    }
    if (index == 2 && _selectedFilterIndex == 2 && _selectedFormat != 'All') {
      return '$base: $_selectedFormat';
    }
    if (index == 3 && _selectedFilterIndex == 3) {
      return '$base: $_selectedDateSort';
    }
    return base;
  }

  List<String> _formatOptions() {
    final formats = <String>{};
    for (final cinema in _cinemas) {
      for (final amenity in cinema.amenities) {
        final lower = amenity.toLowerCase();
        if (lower.contains('imax')) formats.add('IMAX');
        if (lower.contains('3d')) formats.add('3D');
        if (lower.contains('dolby')) formats.add('Dolby');
        if (lower.contains('vip')) formats.add('VIP');
      }
    }
    final list = formats.toList()..sort();
    return ['All', ...list];
  }

  void _onFilterTap(int index) {
    setState(() => _selectedFilterIndex = index);

    if (_filters[index] == 'Nearby') {
      _showNearbySheet();
    } else if (_filters[index] == 'Format') {
      _showFormatSheet();
    } else if (_filters[index] == 'Date') {
      _showDateSheet();
    }
  }

  void _showNearbySheet() {
    final options = <String, double?>{
      'All': null,
      '5 km': 5,
      '10 km': 10,
      '25 km': 25,
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: options.entries.map((entry) {
          final isSelected = _nearbyRadiusKm == entry.value;
          return ListTile(
            title: Text(entry.key, style: const TextStyle(color: Colors.white)),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF4FC3F7)) : null,
            onTap: () {
              setState(() => _nearbyRadiusKm = entry.value);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showFormatSheet() {
    final options = _formatOptions();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: options.map((format) {
          final isSelected = _selectedFormat == format;
          return ListTile(
            title: Text(format, style: const TextStyle(color: Colors.white)),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF4FC3F7)) : null,
            onTap: () {
              setState(() => _selectedFormat = format);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showDateSheet() {
    const options = ['Newest', 'Oldest'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: options.map((option) {
          final isSelected = _selectedDateSort == option;
          return ListTile(
            title: Text(option, style: const TextStyle(color: Colors.white)),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF4FC3F7)) : null,
            onTap: () {
              setState(() => _selectedDateSort = option);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  List<Cinema> _filteredCinemas() {
    var items = List<Cinema>.from(_cinemas);

    if (_selectedFilterIndex == 0) {
      if (_gps.userPosition != null) {
        items.sort((a, b) => _gps.distanceToCinema(a).compareTo(_gps.distanceToCinema(b)));
        if (_nearbyRadiusKm != null) {
          items = items.where((c) => _gps.distanceToCinema(c) <= _nearbyRadiusKm!).toList();
        }
      }
    } else if (_selectedFilterIndex == 1) {
      items = items.where((c) => _favoriteCinemaIds.contains(c.id)).toList();
    } else if (_selectedFilterIndex == 2) {
      if (_selectedFormat != 'All') {
        final lower = _selectedFormat.toLowerCase();
        items = items.where((c) => c.amenities.any((a) => a.toLowerCase().contains(lower))).toList();
      }
    } else if (_selectedFilterIndex == 3) {
      items.sort((a, b) => _selectedDateSort == 'Newest'
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCinemas = _filteredCinemas();
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
                      onTap: () => _onFilterTap(index),
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
                              _filterLabel(index),
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
                          : filteredCinemas.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No cinemas match this filter',
                                    style: TextStyle(color: Color(0xFFB0B0B0)),
                                  ),
                                )
                              : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredCinemas.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final cinema = filteredCinemas[index];
                                final distanceKm = _gps.userPosition != null
                                    ? _gps.distanceToCinema(cinema)
                                    : null;
                                final isNearby = distanceKm != null && distanceKm <= (_nearbyRadiusKm ?? 9999);
                                return _buildCinemaCard(
                                  icon: Icons.theaters_outlined,
                                  name: cinema.name,
                                  address: cinema.address.isNotEmpty ? cinema.address : cinema.city,
                                  distance: distanceKm != null
                                      ? '${distanceKm.toStringAsFixed(1)} km'
                                      : (cinema.city.isNotEmpty ? cinema.city : '—'),
                                  isNearby: isNearby,
                                  features: cinema.amenities.isNotEmpty
                                      ? cinema.amenities
                                      : ['Accessible'],
                                  isFavorite: _favoriteCinemaIds.contains(cinema.id),
                                  onFavoriteTap: () {
                                    setState(() {
                                      if (_favoriteCinemaIds.contains(cinema.id)) {
                                        _favoriteCinemaIds.remove(cinema.id);
                                      } else {
                                        _favoriteCinemaIds.add(cinema.id);
                                      }
                                    });
                                  },
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
    required VoidCallback onFavoriteTap,
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
              GestureDetector(
                onTap: onFavoriteTap,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? const Color(0xFF4FC3F7)
                      : const Color(0xFFB0B0B0),
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
