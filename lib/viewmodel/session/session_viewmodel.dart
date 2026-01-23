import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/local_storage.dart';

class SessionViewModel extends ChangeNotifier {
  final LocalStorage storage;
  SessionViewModel(this.storage);

  bool signedIn = false;
  UserProfile? user;
  String? accessToken;

  Future<void> load() async {
    final userJson = await storage.getString(storage.kUser);
    final token = await storage.getString(storage.kAccessToken);
    if (userJson != null) {
      try {
        user = UserProfile.fromJson(storage.decodeJson(userJson));
        signedIn = user != null;
      } catch (_) {
        user = null;
        signedIn = false;
      }
    }
    accessToken = token?.isNotEmpty == true ? token : null;
    notifyListeners();
  }

  Future<void> signInFromAPI({
    required String email,
    required String userId,
    String? fullName,
    String? token,
  }) async {
    signedIn = true;
    accessToken = token;
    user = UserProfile(id: userId, email: email, fullName: fullName ?? '');
    await storage.setString(storage.kUser, storage.encodeJson(user!.toJson()));
    if (token != null && token.isNotEmpty) {
      await storage.setString(storage.kAccessToken, token);
    } else {
      await storage.remove(storage.kAccessToken);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    signedIn = false;
    user = null;
    accessToken = null;
    await storage.remove(storage.kUser);
    await storage.remove(storage.kAccessToken);
    notifyListeners();
  }

  Future<void> completeProfile({
    required String fullName,
    DateTime? dob,
    String? avatarPath,
    List<String>? favoriteGenres,
    bool newsletter = false,
  }) async {
    if (user == null) return;
    user!.fullName = fullName;
    user!.dob = dob;
    user!.avatarPath = avatarPath;
    user!.favoriteGenres = favoriteGenres ?? [];
    user!.receiveNewsletter = newsletter;

    await storage.setString(storage.kUser, storage.encodeJson(user!.toJson()));
    notifyListeners();
  }
}
