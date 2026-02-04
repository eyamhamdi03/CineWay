import 'package:flutter/foundation.dart';
import '../../services/local_storage.dart';
import '../session/session_viewmodel.dart';

class FavoriteMoviesViewModel extends ChangeNotifier {
  FavoriteMoviesViewModel({
    required this.storage,
    required this.session,
  }) {
    _sessionListener = () => loadFavorites();
    session.addListener(_sessionListener!);
    loadFavorites();
  }

  final LocalStorage storage;
  final SessionViewModel session;

  List<int> _favoriteIds = [];
  VoidCallback? _sessionListener;

  List<int> get favoriteIds => List.unmodifiable(_favoriteIds);

  String _keyForUser() {
    final userId = session.user?.id;
    return 'favoriteMovies_${userId ?? 'guest'}';
  }

  Future<void> loadFavorites() async {
    final key = _keyForUser();
    final values = await storage.getStringList(key);
    _favoriteIds = values.map((e) => int.tryParse(e)).whereType<int>().toList();
    notifyListeners();
  }

  bool isFavorite(int movieId) => _favoriteIds.contains(movieId);

  Future<void> toggleFavorite(int movieId) async {
    if (_favoriteIds.contains(movieId)) {
      _favoriteIds.remove(movieId);
    } else {
      _favoriteIds.add(movieId);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> removeFavorite(int movieId) async {
    _favoriteIds.remove(movieId);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final key = _keyForUser();
    final values = _favoriteIds.map((e) => e.toString()).toList();
    await storage.setStringList(key, values);
  }

  @override
  void dispose() {
    if (_sessionListener != null) {
      session.removeListener(_sessionListener!);
    }
    super.dispose();
  }
}
