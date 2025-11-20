import 'package:flutter/material.dart';
import 'package:cineway/screens/home_screen.dart';
import 'package:cineway/screens/bookings_screen.dart';
import 'package:cineway/screens/movies_screen.dart';
import 'package:cineway/screens/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final List<Widget> pages = [
    HomeScreen(),
    BookingsScreen(),
    MoviesScreen(),
    ProfileScreen(),
  ];

  int mCurrentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: mCurrentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: mCurrentIndex,
        onTap: (index) {
          setState(() {
            mCurrentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity_outlined),
            label: "My Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
