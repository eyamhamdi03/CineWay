import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String? id;
  String? email;
  String? fullName;
  String? avatarPath;
  DateTime? dob;
  List<String> favoriteGenres = [];
  bool receiveNewsletter = false;

  UserProfile({this.id, this.email, this.fullName});

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'avatarPath': avatarPath,
        'dob': dob?.toIso8601String(),
        'favoriteGenres': favoriteGenres,
        'receiveNewsletter': receiveNewsletter,
      };

  static UserProfile? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    final u = UserProfile(id: j['id'], email: j['email'], fullName: j['fullName']);
    if (j['dob'] != null) {
      try {
        u.dob = DateTime.parse(j['dob']);
      } catch (_) {}
    }
    if (j['favoriteGenres'] is List) {
      u.favoriteGenres = List<String>.from(j['favoriteGenres']);
    }
    u.avatarPath = j['avatarPath'];
    u.receiveNewsletter = j['receiveNewsletter'] == true;
    return u;
  }
}

class Booking {
  final String id;
  final String movieTitle;
  final String dateTime;
  final String cinema;
  final String seats;

  Booking({required this.id, required this.movieTitle, required this.dateTime, required this.cinema, required this.seats});

  Map<String, dynamic> toJson() => {
        'id': id,
        'movieTitle': movieTitle,
        'dateTime': dateTime,
        'cinema': cinema,
        'seats': seats,
      };

  static Booking fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'] ?? '',
        movieTitle: j['movieTitle'] ?? '',
        dateTime: j['dateTime'] ?? '',
        cinema: j['cinema'] ?? '',
        seats: j['seats'] ?? '',
      );
}

class AppState extends ChangeNotifier {
  bool _signedIn = false;
  UserProfile? _user;
  bool _isDark = true;
  String _language = 'en';
  final List<Booking> _bookings = [];

  bool get isSignedIn => _signedIn;
  UserProfile? get user => _user;
  bool get isDark => _isDark;
  String get language => _language;
  List<Booking> get bookings => List.unmodifiable(_bookings);

  // load persisted preferences/bookings/user
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? _isDark;
    _language = prefs.getString('language') ?? _language;

    final bJson = prefs.getStringList('bookings') ?? [];
    _bookings.clear();
    for (final s in bJson) {
      try {
        final m = json.decode(s) as Map<String, dynamic>;
        _bookings.add(Booking.fromJson(m));
      } catch (_) {}
    }

    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        final m = json.decode(userJson) as Map<String, dynamic>;
        _user = UserProfile.fromJson(m);
        if (_user != null) _signedIn = true;
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    await prefs.setString('language', _language);

    final bJson = _bookings.map((b) => json.encode(b.toJson())).toList();
    await prefs.setStringList('bookings', bJson);

    if (_user != null) {
      await prefs.setString('user', json.encode(_user!.toJson()));
    } else {
      await prefs.remove('user');
    }
  }

  // Authentication (mock)
  Future<bool> signUp(String email, String password) async {
    // simple mock signup: create user and mark signed in
    await Future.delayed(const Duration(milliseconds: 400));
    _user = UserProfile(id: DateTime.now().millisecondsSinceEpoch.toString(), email: email);
    _signedIn = true;
    await _savePrefs();
    notifyListeners();
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // mock success
    _user = UserProfile(id: 'u-${email.hashCode}', email: email, fullName: '');
    _signedIn = true;
    await _savePrefs();
    notifyListeners();
    return true;
  }

  void signOut() {
    _signedIn = false;
    _user = null;
    _savePrefs();
    notifyListeners();
  }

  // Profile setup
  void completeProfile({required String fullName, DateTime? dob, String? avatarPath, List<String>? favoriteGenres, bool newsletter = false}) {
    if (_user == null) return;
    _user!.fullName = fullName;
    _user!.dob = dob;
    _user!.avatarPath = avatarPath;
    _user!.favoriteGenres = favoriteGenres ?? [];
    _user!.receiveNewsletter = newsletter;
    _savePrefs();
    notifyListeners();
  }

  // Theme
  void toggleTheme() {
    _isDark = !_isDark;
    _savePrefs();
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    _savePrefs();
    notifyListeners();
  }

  // Bookings
  void addBooking(Booking booking) {
    _bookings.add(booking);
    _savePrefs();
    notifyListeners();
  }

  void clearBookings() {
    _bookings.clear();
    _savePrefs();
    notifyListeners();
  }
}
