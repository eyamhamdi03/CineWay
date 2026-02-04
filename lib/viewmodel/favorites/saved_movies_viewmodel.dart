import 'package:flutter/foundation.dart';
import '../../services/local_storage.dart';
import '../session/session_viewmodel.dart';

class SavedMoviesViewModel extends ChangeNotifier {
  SavedMoviesViewModel({
    required this.storage,
    required this.session,
  }) {
    _sessionListener = () => loadSaved();
    session.addListener(_sessionListener!);
    loadSaved();
  }

  final LocalStorage storage;
  final SessionViewModel session;

  List<int> _savedIds = [];
  VoidCallback? _sessionListener;

  List<int> get savedIds => List.unmodifiable(_savedIds);

  String _keyForUser() {
    final userId = session.user?.id;
    return 'savedMovies_${userId ?? 'guest'}';
  }

  Future<void> loadSaved() async {
    final key = _keyForUser();
    final values = await storage.getStringList(key);
    _savedIds = values.map((e) => int.tryParse(e)).whereType<int>().toList();
    notifyListeners();
  }

  bool isSaved(int movieId) => _savedIds.contains(movieId);

  Future<void> toggleSaved(int movieId) async {
    if (_savedIds.contains(movieId)) {
      _savedIds.remove(movieId);
    } else {
      _savedIds.add(movieId);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> removeSaved(int movieId) async {
    _savedIds.remove(movieId);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final key = _keyForUser();
    final values = _savedIds.map((e) => e.toString()).toList();
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
