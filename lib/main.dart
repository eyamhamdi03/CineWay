import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/colors.dart';
import 'l10n/app_localizations.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/cinemas_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/booking_confirmation_screen.dart';

import 'repository/movie_repository.dart';
import 'repository/cinema_repository.dart';
import 'repository/auth_repository.dart';

import 'viewmodel/movie/movie_detail_viewmodel.dart';
import 'viewmodel/search_viewmodel.dart';
import 'viewmodel/auth_view_model.dart';

import 'services/app_state.dart';
import 'services/local_storage.dart';
import 'viewmodel/settings/settings_viewmodel.dart';
import 'viewmodel/session/session_viewmodel.dart';
import 'viewmodel/bookings/bookings_viewmodel.dart';

void main() {
  final storage = LocalStorage();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalStorage>.value(value: storage),
        ChangeNotifierProvider(create: (_) => AppState()..load()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel(storage)..load()),
        ChangeNotifierProvider(create: (_) => SessionViewModel(storage)..load()),
        ChangeNotifierProvider(create: (_) => BookingsViewModel(storage)..load()),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            authRepository: AuthRepository(),
            session: context.read<SessionViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(
            movieRepo: MovieRepository(),
            cinemaRepo: CinemaRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MovieDetailViewModel(MovieRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(builder: (context, settings, _) {
      return MaterialApp(
        title: 'CineWay',
        debugShowCheckedModeBanner: false,
        locale: Locale(settings.language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        initialRoute: '/get_started',
        routes: {
          '/get_started': (_) => const GetStartedScreen(),
          '/login': (_) => const LoginScreen(),
          '/profile_setup': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return ProfileSetupScreen(
              isInitialSetup: args?['isInitialSetup'] ?? false,
            );
          },
          '/home': (context) => MainNavigator(
                initialIndex:
                    (ModalRoute.of(context)?.settings.arguments as int?) ?? 0,
              ),
          '/bookings': (_) => const BookingsScreen(),
          '/booking_confirmation': (_) =>
              const BookingConfirmationScreen(),
        },
      );
    });
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;

  late final AnimationController _fabController;
  late final Animation<double> _scaleAnim;

  final List<Widget> _screens = const [
    HomeScreen(),
    CinemasScreen(),
    SearchScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: Curves.easeInOut,
      ),
    );

    _fabController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final showLabels = MediaQuery.of(context).size.width > 360;

    return Scaffold(
      body: _screens[_selectedIndex],

      /// 🔵 Animated glowing search FAB (SAFE)
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 16),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withOpacity(0.5),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => _onItemTapped(2),
              backgroundColor: const Color(0xFF4FC3F7),
              elevation: 0,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.search,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1A1A1A),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        height: 64 + bottomInset,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0, showLabels),
                _buildNavItem(Icons.theaters_outlined, Icons.theaters, 'Cinemas', 1, showLabels),
                const SizedBox(width: 56),
                _buildNavItem(Icons.confirmation_number_outlined,
                    Icons.confirmation_number, 'Tickets', 3, showLabels),
                _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4, showLabels),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData selectedIcon,
    String label,
    int index,
    bool showLabel,
  ) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF4FC3F7)
                  : const Color(0xFF7A7A7A),
            ),
            if (showLabel)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.1,
                    color: isSelected
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFF7A7A7A),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
