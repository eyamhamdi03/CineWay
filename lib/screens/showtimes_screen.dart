import 'package:flutter/material.dart';
import '../core/colors.dart';

class ShowtimesScreen extends StatefulWidget {
  const ShowtimesScreen({super.key});

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
    // demo: show selection
    final selections = _selectedTimes.entries.map((e) => '${_cinemas[e.key]['name']}: ${e.value}').join('\n');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(title: const Text('Selected'), content: Text(selections), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2328),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Planet of the Apes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('2h 25m | PG-13 | Action, Sci-Fi', style: TextStyle(color: AppColors.jumbo)),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.black26),
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Icon(Icons.movie, color: Colors.white, size: 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_dates.length, (i) {
          final selected = i == _selectedDateIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(_dates[i], style: TextStyle(color: selected ? Colors.white : AppColors.jumbo)),
              selected: selected,
              onSelected: (_) => setState(() => _selectedDateIndex = i),
              selectedColor: AppColors.dodgerBlue,
              backgroundColor: const Color(0xFF141A20),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
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
            onTap: () => _toggleFilter(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: _filterByTime ? AppColors.dodgerBlue : const Color(0xFF141A20), borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('Time', style: TextStyle(fontWeight: FontWeight.w600))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _toggleFilter(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: !_filterByTime ? AppColors.dodgerBlue : const Color(0xFF141A20), borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('Cinema', style: TextStyle(fontWeight: FontWeight.w600))),
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
        Text(cinema['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(cinema['distance'], style: const TextStyle(color: AppColors.jumbo)),
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
                  color: selected ? AppColors.dodgerBlue : const Color(0xFF141A20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(main, style: TextStyle(color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w700)),
                    if (tag != null) const SizedBox(height: 4),
                    if (tag != null) Text(tag, style: TextStyle(color: selected ? Colors.black : AppColors.dodgerBlue, fontSize: 12, fontWeight: FontWeight.w700)),
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
      backgroundColor: AppColors.mirage,
      appBar: AppBar(
        backgroundColor: AppColors.mirage,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        centerTitle: true,
        title: const Text('Showtimes', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 14),
              _dateChips(),
              const SizedBox(height: 12),
              _filterRow(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_cinemas.length, (i) => _cinemaSection(i, _cinemas[i])),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.dodgerBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
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
