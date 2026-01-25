import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../models/movie.dart';
import '../repository/movie_repository.dart';
import '../repository/showtime_repository.dart';
import 'select_seats_screen.dart';

class ShowtimesScreen extends StatefulWidget {
  final String? movieTitle;
  const ShowtimesScreen({super.key, this.movieTitle});
  @override
  State<ShowtimesScreen> createState() => _ShowtimesScreenState();
}

class _ShowtimesScreenState extends State<ShowtimesScreen> {
  int _selectedDateIndex = 0;
  int? _selectedCinemaId;
  String _timeFilter = 'all';
  Movie? _movie;
  bool _loadingMovie = false;
  bool _loadingShowtimes = false;
 
  final Map<int, _ShowtimeItem> _selectedTimes = {}; // key: cinemaId, value: showtime item
  final _showtimeRepo = ShowtimeRepository();
  final List<_CinemaShowtimes> _cinemaGroups = [];
  final List<DateTime> _dates = [];

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

    if (_movie != null) {
      await _fetchShowtimes();
    }
  }

  Future<void> _fetchShowtimes() async {
    if (_movie == null) return;
    setState(() => _loadingShowtimes = true);
    try {
      final List<Map<String, dynamic>> showtimes = await _showtimeRepo.getShowtimesByMovieDetailed(movieId: _movie!.id);

      final List<_CinemaShowtimes> cinemaGroups = [];
      final List<DateTime> dates = [];

      // Group by cinema and date
      final Map<int, Map<DateTime, List<_ShowtimeItem>>> grouped = {};
      final Map<int, _CinemaInfo> cinemaInfoMap = {};

      for (final s in showtimes) {
        final screeningTime = DateTime.parse(s['screening_time']);
        final date = DateTime(screeningTime.year, screeningTime.month, screeningTime.day);
        final cinemaId = s['room']['cinema']['id'] as int;
        final cinemaName = s['room']['cinema']['name'] as String;
        final cinemaAddress = s['room']['cinema']['address'] as String? ?? '';
        final cinemaCity = s['room']['cinema']['city'] as String? ?? '';

        // Store cinema info
        if (!cinemaInfoMap.containsKey(cinemaId)) {
          cinemaInfoMap[cinemaId] = _CinemaInfo(
            id: cinemaId,
            name: cinemaName,
            address: cinemaAddress,
            city: cinemaCity,
          );
        }

        grouped.putIfAbsent(cinemaId, () => {});
        grouped[cinemaId]!.putIfAbsent(date, () => []);
        grouped[cinemaId]![date]!.add(_ShowtimeItem(
          showtimeId: s['id'] as int,
          time: screeningTime,
          price: (s['price'] as num).toDouble(),
        ));
        if (!dates.contains(date)) dates.add(date);
      }

      dates.sort();

      grouped.forEach((cinemaId, dateMap) {
        final cinemaInfo = cinemaInfoMap[cinemaId]!;
        cinemaGroups.add(_CinemaShowtimes(
          cinemaId: cinemaId,
          cinemaName: cinemaInfo.name,
          distance: cinemaInfo.city.isNotEmpty ? cinemaInfo.city : null,
          dates: dateMap,
        ));
      });

      setState(() {
        _cinemaGroups
          ..clear()
          ..addAll(cinemaGroups);
        _dates
          ..clear()
          ..addAll(dates);
        _selectedTimes.clear();
        _selectedDateIndex = dates.isNotEmpty ? 0 : 0;
        _selectedCinemaId = cinemaGroups.isNotEmpty ? cinemaGroups.first.cinemaId : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load showtimes: $e')));
    } finally {
      if (mounted) setState(() => _loadingShowtimes = false);
    }
  }

  String _monthLabel(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11) as int];
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _selectedCinemaLabel() {
    if (_selectedCinemaId == null) return 'By Cinema';
    final match = _cinemaGroups.where((c) => c.cinemaId == _selectedCinemaId).toList();
    return match.isNotEmpty ? match.first.cinemaName : 'By Cinema';
  }
 
  String _timeFilterLabel() {
    switch (_timeFilter) {
      case 'before18':
        return 'Before 6 PM';
      case 'after18':
        return 'After 6 PM';
      default:
        return 'By Time';
    }
  }
 
  void _openCinemaPicker() {
    if (_cinemaGroups.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F151C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('By Cinema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ..._cinemaGroups.map((c) => ListTile(
                  leading: const Icon(Icons.location_on, color: AppColors.dodgerBlue),
                  title: Text(c.cinemaName),
                  trailing: _selectedCinemaId == c.cinemaId ? const Icon(Icons.check, color: AppColors.dodgerBlue) : null,
                  onTap: () {
                    setState(() => _selectedCinemaId = c.cinemaId);
                    Navigator.pop(context);
                  },
                )),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.white70),
              title: const Text('Show all'),
              onTap: () {
                setState(() => _selectedCinemaId = null);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
 
  void _openTimeFilterPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F151C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('By Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ...[
              {'value': 'all', 'label': 'All Times', 'icon': Icons.schedule},
              {'value': 'before18', 'label': 'Before 6 PM', 'icon': Icons.wb_sunny_outlined},
              {'value': 'after18', 'label': 'After 6 PM', 'icon': Icons.nights_stay},
            ].map((item) => ListTile(
                  leading: Icon(item['icon'] as IconData, color: AppColors.dodgerBlue),
                  title: Text(item['label'] as String),
                  trailing: _timeFilter == item['value'] ? const Icon(Icons.check, color: AppColors.dodgerBlue) : null,
                  onTap: () {
                    setState(() => _timeFilter = item['value'] as String);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
 
  void _selectTime(int cinemaId, _ShowtimeItem item) {
    setState(() => _selectedTimes[cinemaId] = item);
  }

  void _continue() {
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a showtime')));
      return;
    }
    final entry = _selectedTimes.entries.first;
    final cinemaId = entry.key;
    final item = entry.value;
    final date = _dates[_selectedDateIndex];
    final cinemaName = _cinemaGroups.firstWhere((c) => c.cinemaId == cinemaId).cinemaName;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectSeatsScreen(movieTitle: widget.movieTitle, cinema: cinemaName, dateTime: '${date.toIso8601String().split('T').first} • ${_formatTime(item.time)}'),
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
              children: [
                Text(_movie?.title ?? widget.movieTitle ?? 'Movie', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(_movie?.duration ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                    const _Dot(),
                    Text(_movie?.rating ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                    if (_movie != null && _movie!.categories.isNotEmpty) ...[
                      const _Dot(),
                      Text(_movie!.categories.first, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
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
            onTap: () => setState(() {
              _selectedDateIndex = i;
              _selectedTimes.clear();
            }),
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
                  Text(_dates[i].day.toString().padLeft(2, '0'), style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.w600, color: selected ? Colors.blue.shade50 : const Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Text(_monthLabel(_dates[i].month), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          child: GestureDetector(
            onTap: _openCinemaPicker,
            child: Container(
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFF19232D), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 20, color: AppColors.dodgerBlue),
                  const SizedBox(width: 8),
                  Text(_selectedCinemaLabel(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _openTimeFilterPicker,
            child: Container(
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFF19232D), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 20, color: AppColors.dodgerBlue),
                  const SizedBox(width: 8),
                  Text(_timeFilterLabel(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cinemaSection(_CinemaShowtimes cinema) {
    final date = _dates[_selectedDateIndex];
    final times = [...(cinema.dates[date] ?? [])]
      ..retainWhere((t) {
        final hour = t.time.toLocal().hour;
        if (_timeFilter == 'before18') return hour < 18;
        if (_timeFilter == 'after18') return hour >= 18;
        return true;
      })
      ..sort((a, b) => a.time.compareTo(b.time));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cinema.cinemaName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(cinema.distance ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
          ],
        ),
        const SizedBox(height: 10),
        if (times.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No showtimes for selected filters', style: TextStyle(color: Color(0xFF94A3B8))),
          )
        else
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: times.map((t) {
              final label = _formatTime(t.time);
              final selected = _selectedTimes[cinema.cinemaId]?.showtimeId == t.showtimeId;
              return GestureDetector(
                onTap: () => _selectTime(cinema.cinemaId, t),
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
                      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : Colors.white)),
                      const SizedBox(height: 2),
                      Text('₹${t.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.dodgerBlue)),
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
                  _dates.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            _dateChips(),
                            const SizedBox(height: 12),
                            _filterRow(),
                          ],
                        ),
                ],
              ),
            ),
            Expanded(
              child: _loadingShowtimes
                  ? const Center(child: CircularProgressIndicator(color: AppColors.dodgerBlue))
                  : _dates.isEmpty
                      ? const Center(child: Text('No showtimes available'))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _cinemaGroups
                                .where((c) => _selectedCinemaId == null || c.cinemaId == _selectedCinemaId)
                                .map(_cinemaSection)
                                .toList(),
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
            onPressed: _selectedTimes.isEmpty ? null : _continue,
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

class _ShowtimeItem {
  final int showtimeId;
  final DateTime time;
  final double price;

  _ShowtimeItem({required this.showtimeId, required this.time, required this.price});
}

class _CinemaShowtimes {
  final int cinemaId;
  final String cinemaName;
  final String? distance;
  final Map<DateTime, List<_ShowtimeItem>> dates;

  _CinemaShowtimes({required this.cinemaId, required this.cinemaName, required this.distance, required this.dates});
}

class _CinemaInfo {
  final int id;
  final String name;
  final String address;
  final String city;

  _CinemaInfo({required this.id, required this.name, required this.address, required this.city});
}
