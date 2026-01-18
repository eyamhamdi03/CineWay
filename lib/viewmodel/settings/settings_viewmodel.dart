import 'package:flutter/material.dart';
import '../../services/local_storage.dart';

class SettingsViewModel extends ChangeNotifier {
  final LocalStorage storage;
  SettingsViewModel(this.storage);

  bool isDark = true;
  String language = 'en';

  Future<void> load() async {
    isDark = await storage.getBool(storage.kIsDark) ?? isDark;
    language = await storage.getString(storage.kLanguage) ?? language;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    isDark = !isDark;
    await storage.setBool(storage.kIsDark, isDark);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    language = lang;
    await storage.setString(storage.kLanguage, language);
    notifyListeners();
  }
}
