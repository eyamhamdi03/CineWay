import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _kIsDark = 'isDark';
  static const _kLanguage = 'language';
  static const _kUser = 'user';
  static const _kBookings = 'bookings';

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<List<String>> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  // Keys getters (so you reuse exact same keys everywhere)
  String get kIsDark => _kIsDark;
  String get kLanguage => _kLanguage;
  String get kUser => _kUser;
  String get kBookings => _kBookings;

  // helpers
  String encodeJson(Map<String, dynamic> map) => json.encode(map);
  Map<String, dynamic> decodeJson(String s) => json.decode(s) as Map<String, dynamic>;
}
