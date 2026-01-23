import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  Color get _bg => const Color(0xFF0F1622);
  Color get _card => const Color(0xFF18232E);
  Color get _primary => const Color(0xFF55A6F6);
  Color get _textPrimary => const Color(0xFFF5F7F8);
  Color get _textSecondary => const Color(0xFF9CABB9);

  final List<PurchaseItem> _transactions = [
    PurchaseItem(
      title: 'Dune: Part Two',
      date: 'Mar 12, 2026',
      time: '19:30',
      location: 'CineWay Grand Mall, Screen 4',
      tickets: 2,
      price: 28.50,
      status: 'COMPLETED',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBgUTqJL4n8-Iucbk4ktz_IX3pejvNbUuXk1B9yBQX4VQ0zsRrIgetbiVRFsTzjxar-5TJbNwRWu0kVyNBlfPn5h1AOgeoF8ysq7wgxWvm1kStSHWt4z3CeM6fNVCqN8fiz8bsvMSNz4vgcnnb-dHiGt-C_wauHTb8XqAZucmAPdMpwkKXqZRQdTWvaMotdw_UGbW4hKqlvA2KXPY2bUzhEjdS8yAuWDn8KiRjjb3QMJLUpCZiaBQ_WDKwgHim8Ym6Sy2T3kiqoB-k',
      isActive: true,
    ),
    PurchaseItem(
      title: 'Poor Things',
      date: 'Feb 28, 2026',
      time: '21:00',
      location: 'CineWay Downtown',
      tickets: 1,
      price: 14.25,
      status: 'PAST',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBgUTqJL4n8-Iucbk4ktz_IX3pejvNbUuXk1B9yBQX4VQ0zsRrIgetbiVRFsTzjxar-5TJbNwRWu0kVyNBlfPn5h1AOgeoF8ysq7wgxWvm1kStSHWt4z3CeM6fNVCqN8fiz8bsvMSNz4vgcnnb-dHiGt-C_wauHTb8XqAZucmAPdMpwkKXqZRQdTWvaMotdw_UGbW4hKqlvA2KXPY2bUzhEjdS8yAuWDn8KiRjjb3QMJLUpCZiaBQ_WDKwgHim8Ym6Sy2T3kiqoB-k',
      isActive: false,
    ),
    PurchaseItem(
      title: 'Oppenheimer',
      date: 'Jan 15, 2026',
      time: '14:00',
      location: 'CineWay IMAX Hub',
      tickets: 3,
      price: 52.00,
      status: 'PAST',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBgUTqJL4n8-Iucbk4ktz_IX3pejvNbUuXk1B9yBQX4VQ0zsRrIgetbiVRFsTzjxar-5TJbNwRWu0kVyNBlfPn5h1AOgeoF8ysq7wgxWvm1kStSHWt4z3CeM6fNVCqN8fiz8bsvMSNz4vgcnnb-dHiGt-C_wauHTb8XqAZucmAPdMpwkKXqZRQdTWvaMotdw_UGbW4hKqlvA2KXPY2bUzhEjdS8yAuWDn8KiRjjb3QMJLUpCZiaBQ_WDKwgHim8Ym6Sy2T3kiqoB-k',
      isActive: false,
    ),
    PurchaseItem(
      title: 'Spider-Man: Across the Universe',
      date: 'Dec 22, 2025',
      time: '18:45',
      location: 'CineWay Grand Mall',
      tickets: 2,
      price: 30.00,
      status: 'PAST',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBgUTqJL4n8-Iucbk4ktz_IX3pejvNbUuXk1B9yBQX4VQ0zsRrIgetbiVRFsTzjxar-5TJbNwRWu0kVyNBlfPn5h1AOgeoF8ysq7wgxWvm1kStSHWt4z3CeM6fNVCqN8fiz8bsvMSNz4vgcnnb-dHiGt-C_wauHTb8XqAZucmAPdMpwkKXqZRQdTWvaMotdw_UGbW4hKqlvA2KXPY2bUzhEjdS8yAuWDn8KiRjjb3QMJLUpCZiaBQ_WDKwgHim8Ym6Sy2T3kiqoB-k',
      isActive: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PurchaseItem> get _filteredTransactions {
    if (_searchQuery.isEmpty) {
      return _transactions;
    }
    return _transactions
        .where((item) =>
            item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.location.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF55A6F6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.purchase_history,
          style: const TextStyle(
            color: Color(0xFFF5F7F8),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFFF5F7F8)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: localizations.search_transactions,
                    hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: _textSecondary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Transactions List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredTransactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _transactionCard(_filteredTransactions[index], localizations);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Load Older Button
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      localizations.load_older_transactions,
                      style: TextStyle(
                        color: _primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Footer
                  Text(
                    'CineWay Version 2.4.0',
                    style: TextStyle(
                      color: _textSecondary.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionCard(PurchaseItem item, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Movie Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 64,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.withOpacity(0.3),
                          child: const Icon(Icons.movie, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.status == 'COMPLETED'
                                  ? _primary.withOpacity(0.15)
                                  : Colors.transparent,
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                color: item.status == 'COMPLETED' ? _primary : _textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Date and Time
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: _textSecondary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${item.date} • ${item.time}',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: _textSecondary, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Tickets and Price
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.tickets} ${item.tickets == 1 ? localizations.ticket : localizations.tickets}',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: _primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PurchaseItem {
  final String title;
  final String date;
  final String time;
  final String location;
  final int tickets;
  final double price;
  final String status;
  final String imageUrl;
  final bool isActive;

  PurchaseItem({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.tickets,
    required this.price,
    required this.status,
    required this.imageUrl,
    required this.isActive,
  });
}
