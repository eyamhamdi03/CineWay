import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../data/mock_movies.dart';
import '../widgets/common/search_bar.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0; // 0 = Now Showing, 1 = Coming Soon
  int _featuredIndex = 0;

  @override
  Widget build(BuildContext context) {
    final featured = mockMovies.isNotEmpty ? mockMovies[0] : null;
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CineWay', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Hello, Jane!', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications (demo)'))), icon: Icon(Icons.notifications_none, color: textColor)),
                ],
              ),
            ),

            // Search bar
            Padding(padding: const EdgeInsets.symmetric(horizontal: 18.0), child: CustomSearchBar(placeholder: 'Search movies, theaters...')),
            const SizedBox(height: 12),

            // Featured carousel
            SizedBox(
              height: 260,
              child: PageView.builder(
                itemCount: featured != null ? 1 : 0,
                controller: PageController(viewportFraction: 0.88),
                onPageChanged: (i) => setState(() => _featuredIndex = i),
                itemBuilder: (context, index) {
                  final movie = featured!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(18)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: movie.bannerUrl.isNotEmpty ? Image.asset(movie.bannerUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: colorScheme.background)) : Container(color: colorScheme.background),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movie.title, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text(movie.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor.withOpacity(0.7))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            // Tabs: Now Showing / Coming Soon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _tabIndex = 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Now Showing', style: TextStyle(color: _tabIndex == 0 ? AppColors.dodgerBlue : Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(height: 3, width: 120, decoration: BoxDecoration(color: _tabIndex == 0 ? AppColors.dodgerBlue : Colors.transparent, borderRadius: BorderRadius.circular(2))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  GestureDetector(
                    onTap: () => setState(() => _tabIndex = 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Coming Soon', style: TextStyle(color: _tabIndex == 1 ? AppColors.dodgerBlue : Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(height: 3, width: 120, decoration: BoxDecoration(color: _tabIndex == 1 ? AppColors.dodgerBlue : Colors.transparent, borderRadius: BorderRadius.circular(2))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Movies grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 16, top: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: mockMovies.length >= 6 ? 6 : mockMovies.length,
                  itemBuilder: (context, index) {
                    final m = mockMovies[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: 0,))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 160,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFF0F1618)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: m.bannerUrl.isNotEmpty ? Image.asset(m.bannerUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B1113))) : Container(color: const Color(0xFF0B1113)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(m.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(m.categories.isNotEmpty ? m.categories[0] : '', style: const TextStyle(color: AppColors.jumbo)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
