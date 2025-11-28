import 'package:flutter/material.dart';
import '../core/colors.dart';
import 'select_seats_screen.dart';

class ShowtimesScreen extends StatefulWidget {
  final String? movieTitle;

  const ShowtimesScreen({super.key, this.movieTitle});

  @override
  State<ShowtimesScreen> createState() => _ShowtimesScreenState();
}

class _ShowtimesScreenState extends State<ShowtimesScreen> {
  int _selectedDateIndex = 0;
  bool _filterByTime = true; // true=Time, false=Cinema

  // sample data
  final List<String> _dates = ['Today, Aug 15', 'Tomorrow, Aug 16', 'Fri, Aug 17'];

  final List<Map<String, dynamic>> _cinemas = [
    {
      'name': 'Cineplex Downtown',
      'distance': '2.5 km away',
      'times': ['18:45', '19:30', '20:15', '21:00']
    },
    {
      'name': 'Grand Millennium',
      'distance': '4.1km away',
      'times': ['19:00 IMAX', '19:45', '21:30 IMAX', '22:00']
    },
    {
      'name': 'Starlight Cinemas',
      'distance': '6.8 km away',
      'times': ['17:30', '19:15', '20:45 3D']
    },
  ];

  // track selected time per cinema index
  final Map<int, String> _selectedTimes = {};

  void _toggleFilter(bool byTime) => setState(() => _filterByTime = byTime);

  void _selectTime(int cinemaIndex, String time) {
    setState(() {
      _selectedTimes[cinemaIndex] = time;
    });
  }

  void _continue() {
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a showtime')));
      return;
    }
    // navigate to seat selection for the first selected showtime
    final firstEntry = _selectedTimes.entries.first;
    final cinema = _cinemas[firstEntry.key]['name'] as String;
    final time = firstEntry.value as String;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectSeatsScreen(movieTitle: widget.movieTitle, cinema: cinema, dateTime: time),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.movieTitle ?? 'Movie', style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('2h 25m | PG-13 | Action, Sci-Fi', style: TextStyle(color: AppColors.jumbo)),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: cs.onSurface.withOpacity(0.06)),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Icon(Icons.movie, color: cs.onSurface, size: 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChips(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_dates.length, (i) {
          final selected = i == _selectedDateIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(_dates[i], style: TextStyle(color: selected ? cs.onPrimary : cs.onSurface.withOpacity(0.85))),
              selected: selected,
              onSelected: (_) => setState(() => _selectedDateIndex = i),
              selectedColor: cs.primary,
              backgroundColor: cs.surfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        }),
      ),
    );
  }

  Widget _filterRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _toggleFilter(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: _filterByTime ? cs.primary : cs.surfaceVariant, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('Time', style: TextStyle(fontWeight: FontWeight.w600, color: _filterByTime ? cs.onPrimary : cs.onSurface))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _toggleFilter(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: !_filterByTime ? cs.primary : cs.surfaceVariant, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('Cinema', style: TextStyle(fontWeight: FontWeight.w600, color: !_filterByTime ? cs.onPrimary : cs.onSurface))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cinemaSection(BuildContext context, int index, Map<String, dynamic> cinema) {
    final cs = Theme.of(context).colorScheme;
    final times = (cinema['times'] as List<String>);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(cinema['name'], style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(cinema['distance'], style: TextStyle(color: AppColors.jumbo)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: times.map((t) {
            final selected = _selectedTimes[index] == t;
            // show small tag if contains IMAX or 3D
            final parts = t.split(' ');
            final main = parts[0];
            final tag = parts.length > 1 ? parts[1] : null;
            return GestureDetector(
              onTap: () => _selectTime(index, t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? cs.primary : cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(main, style: TextStyle(color: selected ? cs.onPrimary : cs.onSurface, fontWeight: FontWeight.w700)),
                    if (tag != null) const SizedBox(height: 4),
                    if (tag != null) Text(tag, style: TextStyle(color: selected ? cs.onPrimary : AppColors.dodgerBlue, fontSize: 12, fontWeight: FontWeight.w700)),
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor), onPressed: () => Navigator.maybePop(context)),
        centerTitle: true,
        title: Text('Showtimes', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).appBarTheme.foregroundColor)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 14),
              _dateChips(context),
              const SizedBox(height: 12),
              _filterRow(context),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_cinemas.length, (i) => _cinemaSection(context, i, _cinemas[i])),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(backgroundColor: cs.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
