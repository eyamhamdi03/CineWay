import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/session/session_viewmodel.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SessionViewModel _session;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;

  AuthViewModel({
    required AuthRepository authRepository,
    required SessionViewModel session,
  })  : _authRepository = authRepository,
        _session = session;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign up (API)
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.signUp(email, password);
      // After registration, perform a login to obtain access token and profile
      // data (the register endpoint does not return a token).
      final loginResult = await _authRepository.signIn(email, password);
      final accessToken = (loginResult['access_token'] ?? loginResult['token'] ?? '').toString();
      if (accessToken.isEmpty) {
        throw Exception('Missing access token after registration');
      }

      return await _loginWithToken(accessToken);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in (API)
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.signIn(email, password);

      final accessToken = (result['access_token'] ?? result['token'] ?? '').toString();
      if (accessToken.isEmpty) {
        throw Exception('Missing access token');
      }

      return await _loginWithToken(accessToken);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _loginWithToken(String accessToken) async {
    try {
      final me = await _authRepository.fetchCurrentUser(accessToken);
      final email = me['email']?.toString() ?? '';
      final userId = (me['id'] ?? me['user_id'] ?? 'u-${email.hashCode}').toString();
      final fullName = me['full_name']?.toString();

      await _session.signInFromAPI(
        email: email,
        userId: userId,
        fullName: fullName,
        token: accessToken,
      );

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _session.signOut();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Sign out failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ok = await _authRepository.requestPasswordReset(email);
      _isLoading = false;
      notifyListeners();
      return ok;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final email = value.trim();
    final regex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!regex.hasMatch(email)) return 'Please enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validatePasswordConfirmation(String? value, String passwordValue) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordValue) return 'Passwords do not match';
    return null;
  }
}
