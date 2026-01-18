import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../widgets/common/search_bar.dart';
import '../widgets/common/tab_item.dart';
import 'details_screen.dart';

import '../models/movie.dart';
import '../repository/movie_repository.dart';
import 'package:provider/provider.dart';
import '../viewmodel/session/session_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0; // 0 = Now Showing, 1 = Coming Soon
  int _featuredIndex = 0;

  final _repo = MovieRepository();

  bool _loading = true;
  String? _error;
  List<Movie> _allMovies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final movies = await _repo.getAllMovies();
      setState(() => _allMovies = movies);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Movie> get _nowPlaying {
    final today = DateTime.now();
    return _allMovies.where((m) {
      final d = m.releaseDate;
      if (d == null) return true; // if unknown, show in now playing
      return !d.isAfter(DateTime(today.year, today.month, today.day));
    }).toList();
  }

  List<Movie> get _comingSoon {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    return _allMovies.where((m) {
      final d = m.releaseDate;
      if (d == null) return false;
      return d.isAfter(t);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final name = (session.user?.fullName?.trim().isNotEmpty ?? false)
        ? session.user!.fullName!.trim()
        : (session.user?.email?.split('@').first ?? 'Guest');

    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    final moviesForTab = _tabIndex == 0 ? _nowPlaying : _comingSoon;
    final featured = moviesForTab.isNotEmpty ? moviesForTab.first : null;
    List<Movie> _top5(List<Movie> list) => list.take(5).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 16),
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
                        Text('CineWay',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            )),
                        const SizedBox(height: 4),
                        Text(
                          'Hello, $name!',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),

                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications (demo)')),
                    ),
                    icon: Icon(Icons.notifications_none, color: textColor),
                  ),
                ],
              ),
            ),

           
            const SizedBox(height: 12),

            // Loading / Error
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadMovies,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else ...[
                // Featured carousel (1 item for now)
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
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: movie.bannerUrl.isNotEmpty
                                    ? Image.network(
                                  movie.bannerUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: colorScheme.background),
                                )
                                    : Container(color: colorScheme.background),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(movie.title,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      )),
                                  const SizedBox(height: 6),
                                  Text(
                                    movie.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: textColor.withOpacity(0.7)),
                                  ),
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

                // Tabs (no overflow)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TabItem(
                          label: 'Now Showing',
                          active: _tabIndex == 0,
                          onTap: () => setState(() => _tabIndex = 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TabItem(
                          label: 'Coming Soon',
                          active: _tabIndex == 1,
                          onTap: () => setState(() => _tabIndex = 1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Movies grid
                // Horizontal movies row (only 5)
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
    child: SizedBox(
    height: 240, // one line height
    child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: _top5(moviesForTab).length,
    itemBuilder: (context, index) {
    final m = _top5(moviesForTab)[index];

    return GestureDetector(
    onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => MovieDetailsScreen(movieId: m.id),
    ),
    ),
    child: Container(
    width: 150,
    margin: EdgeInsets.only(
    left: index == 0 ? 0 : 12,
    right: index == _top5(moviesForTab).length - 1 ? 0 : 0,
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // poster
    Container(
    height: 170,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: const Color(0xFF0F1618),
    ),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: m.bannerUrl.isNotEmpty
    ? Image.network(
    m.bannerUrl,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) =>
    Container(color: const Color(0xFF0B1113)),
    )
        : Container(color: const Color(0xFF0B1113)),
    ),
    ),
    const SizedBox(height: 8),

    Text(
    m.title,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w800,
    ),
    ),
    const SizedBox(height: 6),
    Text(
    m.categories.isNotEmpty ? m.categories.first : '',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(color: AppColors.jumbo),
    ),
    ],
    ),
    ),
    );
    },
    ),
    ),
    ),

              ],
          ],
        ),
      ),
    );
  }
}

