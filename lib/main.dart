// details screen no longer part of bottom nav
import 'package:cineway/screens/home_screen.dart';
import 'package:cineway/screens/login_screen.dart';
import 'package:cineway/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cineway/l10n/app_localizations.dart';

import 'core/colors.dart';
import 'screens/movies_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'services/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final s = AppState();
        s.load();
        return s;
      },
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
        colorScheme: ColorScheme.light(
          primary: AppColors.dodgerBlue,
          secondary: AppColors.mineShaft,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          brightness: Brightness.light,
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
        colorScheme: ColorScheme.dark(
          primary: AppColors.dodgerBlue,
          secondary: AppColors.mineShaft,
          surface: AppColors.nileBlue,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textSecondary,
          brightness: Brightness.dark,
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
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: colorScheme.primary,
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
