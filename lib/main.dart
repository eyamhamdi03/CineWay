import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/colors.dart';
import 'l10n/app_localizations.dart';

import 'screens/details_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/movies_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/booking_confirmation_screen.dart';

import 'services/app_state.dart';
import 'repository/movie_repository.dart';
import 'repository/cinema_repository.dart';

import 'viewmodel/movie/movie_detail_viewmodel.dart';
import 'viewmodel/search_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final s = AppState();
            s.load();
            return s;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => SearchViewModel(
            movieRepo: MovieRepository(),
            cinemaRepo: CinemaRepository(),
          ),
        ),

        // Movie details ViewModel
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
    return Consumer<AppState>(builder: (context, appState, _) {
      final isDark = appState.isDark;

      final lightTheme = ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.dodgerBlue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      );

      final darkTheme = ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.dodgerBlue,
        scaffoldBackgroundColor: AppColors.mirage,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.mirage,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );

      return MaterialApp(
        title: 'CineWay',
        debugShowCheckedModeBanner: false,
        locale: Locale(appState.language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/get_started',
        routes: {
          '/get_started': (ctx) => const GetStartedScreen(),
          '/login': (ctx) => const LoginScreen(),
          '/profile_setup': (ctx) => const ProfileSetupScreen(),
          '/home': (ctx) => const MainNavigator(),
          '/bookings': (ctx) => const BookingsScreen(),
          '/booking_confirmation': (ctx) => const BookingConfirmationScreen(),
        },
      );
    });
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MoviesScreen(),
    const SearchScreen(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: loc.home),
          BottomNavigationBarItem(icon: const Icon(Icons.movie), label: loc.movies),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: loc.search),
          BottomNavigationBarItem(icon: const Icon(Icons.bookmark), label: loc.bookings),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: loc.profile),
        ],
      ),
    );
  }
}
