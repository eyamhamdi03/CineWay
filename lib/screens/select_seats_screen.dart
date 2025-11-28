import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../data/mock_movies.dart';
import 'payment_screen.dart';

class SelectSeatsScreen extends StatefulWidget {
  const SelectSeatsScreen({super.key});

  @override
  State<SelectSeatsScreen> createState() => _SelectSeatsScreenState();
}

class _SelectSeatsScreenState extends State<SelectSeatsScreen> {
  // Rows A - G
  final List<String> _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  final int _cols = 10;

  // occupied seats (sample)
  final Set<String> _occupied = {
    'A3', 'B5', 'C7', 'D2', 'F6', 'G9'
  };

  final Set<String> _selected = {};
  final double _seatPrice = 12.00;
  final int _maxSelectable = 6;

  String _seatKey(int r, int c) => '${_rows[r]}${c + 1}';

  void _toggleSeat(String seat) {
    if (_occupied.contains(seat)) return;
    setState(() {
      if (_selected.contains(seat)) _selected.remove(seat);
      else {
        if (_selected.length >= _maxSelectable) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum seats selected')));
          return;
        }
        _selected.add(seat);
      }
    });
  }

  List<String> _sortedSelected() {
    final list = _selected.toList();
    list.sort((a, b) {
      final ra = a.codeUnitAt(0);
      final rb = b.codeUnitAt(0);
      if (ra != rb) return ra - rb;
      final ca = int.parse(a.substring(1));
      final cb = int.parse(b.substring(1));
      return ca - cb;
    });
    return list;
  }

  void _proceed() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one seat')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentScreen()),
    );
  }

  Widget _buildSeat(String id) {
    final selected = _selected.contains(id);
    final occupied = _occupied.contains(id);
    Color color;
    if (occupied) color = const Color(0xFF2A2E31);
    else if (selected) color = AppColors.dodgerBlue;
    else color = const Color(0xFF1B2024);

    return GestureDetector(
      onTap: () => _toggleSeat(id),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieTitle = mockMovies.isNotEmpty ? mockMovies[0].title : 'Movie';
    final selectedList = _sortedSelected();
    final total = (_selected.length * _seatPrice);

    return Scaffold(
      backgroundColor: AppColors.mirage,
      appBar: AppBar(
        backgroundColor: AppColors.mirage,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        centerTitle: true,
        title: const Text('SelectSeats', style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(movieTitle, style: const TextStyle(color: AppColors.jumbo)),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Screen graphic
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                children: [
                  Container(height: 12, decoration: BoxDecoration(color: AppColors.dodgerBlue, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: AppColors.dodgerBlue.withOpacity(0.35), blurRadius: 14, spreadRadius: 2)])),
                  const SizedBox(height: 8),
                  const Text('SCREEN', style: TextStyle(color: AppColors.jumbo)),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Seat grid with row labels
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: List.generate(_rows.length, (r) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, child: Text(_rows[_rows.length - 1 - r], style: const TextStyle(color: AppColors.jumbo))),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_cols, (c) {
                                // render rows in normal order A bottom -> G top, we invert index above
                                final rowIndex = _rows.length - 1 - r;
                                final id = _seatKey(rowIndex, c);
                                return Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0), child: _buildSeat(id));
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(width: 20, child: Text(_rows[_rows.length - 1 - r], style: const TextStyle(color: AppColors.jumbo))),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 10),
            // Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(children: [Container(width: 18, height: 18, decoration: BoxDecoration(color: AppColors.dodgerBlue, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 8), const Text('Selected', style: TextStyle(color: AppColors.jumbo))]),
                  Row(children: [Container(width: 18, height: 18, decoration: BoxDecoration(color: const Color(0xFF1B2024), borderRadius: BorderRadius.circular(4))), const SizedBox(width: 8), const Text('Available', style: TextStyle(color: AppColors.jumbo))]),
                  Row(children: [Container(width: 18, height: 18, decoration: BoxDecoration(color: const Color(0xFF2A2E31), borderRadius: BorderRadius.circular(4))), const SizedBox(width: 8), const Text('Occupied', style: TextStyle(color: AppColors.jumbo))]),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Bottom summary card and CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: const Color(0xFF1F2629), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tickets(${_selected.length})', style: const TextStyle(color: AppColors.jumbo)),
                            const SizedBox(height: 6),
                            Text(selectedList.isNotEmpty ? selectedList.join(', ') : 'None', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TotalPrice', style: TextStyle(color: AppColors.jumbo)),
                            const SizedBox(height: 6),
                            Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _proceed,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.dodgerBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text('Proceed to Payment', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
