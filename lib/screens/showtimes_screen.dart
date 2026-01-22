import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../models/movie.dart';
import '../repository/movie_repository.dart';
import 'select_seats_screen.dart';

class ShowtimesScreen extends StatefulWidget {
  final String? movieTitle;
  const ShowtimesScreen({super.key, this.movieTitle});
  @override
  State<ShowtimesScreen> createState() => _ShowtimesScreenState();
}

class _ShowtimesScreenState extends State<ShowtimesScreen> {
  int _selectedDateIndex = 0;
  Movie? _movie;
  bool _loadingMovie = false;

  final List<String> _dates = const ['Aug 15', 'Aug 16', 'Aug 17', 'Aug 18', 'Aug 19'];

  final List<Map<String, dynamic>> _cinemas = const [
    {
      'name': 'Cineplex Downtown',
      'distance': '2.5 km',
      'times': ['18:45', '19:30', '20:15', '21:00']
    },
    {
      'name': 'Grand Millennium',
      'distance': '4.1 km',
      'times': ['19:00 IMAX', '19:45', '21:30 IMAX', '22:00']
    },
    {
      'name': 'Starlight Cinemas',
      'distance': '6.8 km',
      'times': ['17:30', '19:15', '20:45 3D']
    },
  ];

  final Map<int, String> _selectedTimes = {};

  @override
  void initState() {
    super.initState();
    _fetchMovie();
  }

  Future<void> _fetchMovie() async {
    final title = widget.movieTitle?.trim();
    if (title == null || title.isEmpty) return;
    setState(() => _loadingMovie = true);
    try {
      final repo = MovieRepository();
      final results = await repo.searchMovies(title);
      if (results.isNotEmpty) setState(() => _movie = results.first);
    } catch (_) {
      // ignore errors, keep placeholder
    } finally {
      if (mounted) setState(() => _loadingMovie = false);
    }
  }

  void _selectTime(int cinemaIndex, String time) {
    setState(() => _selectedTimes[cinemaIndex] = time);
  }

  void _continue() {
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a showtime')));
      return;
    }
    final entry = _selectedTimes.entries.first;
    final cinema = _cinemas[entry.key]['name'] as String;
    final time = entry.value;
    final date = _dates[_selectedDateIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectSeatsScreen(movieTitle: widget.movieTitle, cinema: cinema, dateTime: '$date • $time'),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF19232D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (_movie?.bannerUrl.isNotEmpty == true && !_loadingMovie)
                      ? Image.network(_movie!.bannerUrl, fit: BoxFit.cover, width: 80, height: 120)
                      : Container(color: Colors.grey.shade800, child: const Center(child: Icon(Icons.movie, size: 40, color: Colors.white70))),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Planet of the Apes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text('2h 25m', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                    _Dot(),
                    Text('PG-13', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                    _Dot(),
                    Text('Action', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: List.generate(_dates.length, (i) {
          final selected = i == _selectedDateIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = i),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.dodgerBlue : const Color(0xFF19232D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
                boxShadow: selected ? [BoxShadow(color: AppColors.dodgerBlue.withOpacity(0.25), blurRadius: 16, spreadRadius: 1)] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_dates[i].split(' ')[0], style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.w600, color: selected ? Colors.blue.shade50 : const Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Text(_dates[i].split(' ')[1], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _filterRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFF19232D), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.schedule, size: 20, color: AppColors.dodgerBlue),
                SizedBox(width: 8),
                Text('By Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                SizedBox(width: 4),
                Icon(Icons.expand_more, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFF19232D), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.location_on, size: 20, color: AppColors.dodgerBlue),
                SizedBox(width: 8),
                Text('By Cinema', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                SizedBox(width: 4),
                Icon(Icons.expand_more, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cinemaSection(int index, Map<String, dynamic> cinema) {
    final times = (cinema['times'] as List<String>);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cinema['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(cinema['distance'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: times.map((t) {
            final selected = _selectedTimes[index] == t;
            final parts = t.split(' ');
            final main = parts[0];
            final tag = parts.length > 1 ? parts[1] : null;
            return GestureDetector(
              onTap: () => _selectTime(index, t),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? AppColors.dodgerBlue : const Color(0xFF19232D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                  boxShadow: selected ? [BoxShadow(color: AppColors.dodgerBlue.withOpacity(0.25), blurRadius: 16, spreadRadius: 1)] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(main, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : Colors.white)),
                    if (tag != null) const SizedBox(height: 2),
                    if (tag != null)
                      const SizedBox.shrink(),
                    if (tag != null)
                      Text(tag!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.dodgerBlue)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922).withOpacity(0.95),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        centerTitle: true,
        title: const Text('Showtimes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 14),
                  _dateChips(),
                  const SizedBox(height: 12),
                  _filterRow(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_cinemas.length, (i) => _cinemaSection(i, _cinemas[i])),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _continue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dodgerBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: const Text('Select Seats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF64748B), shape: BoxShape.circle));
  }
}
