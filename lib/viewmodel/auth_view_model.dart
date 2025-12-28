import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final AppState _appState;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isSignedIn => _appState.isSignedIn;
  UserProfile? get user => _appState.user;

  AuthViewModel({
    required AuthRepository authRepository,
    required AppState appState,
  })  : _authRepository = authRepository,
        _appState = appState;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign up with email and password
  /// Returns true on success, false on failure
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API repository
      final result = await _authRepository.signUp(email, password);

      // Update AppState with new user
      _appState.signUpFromAPI(
        email: email,
        userId: result['id'] ?? result['user_id'] ?? '',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  /// Returns true on success, false on failure
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API repository
      final result = await _authRepository.signIn(email, password);

      // Extract token and user data
      final accessToken = result['access_token'] ?? result['token'] ?? '';
      final userId = result['id'] ?? result['user_id'] ?? 'u-${email.hashCode}';

      // Update AppState with logged-in user
      _appState.signInFromAPI(
        email: email,
        userId: userId,
        accessToken: accessToken,
      );

      _isLoading = false;
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
      _appState.signOut();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Sign out failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.requestPasswordReset(email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final email = value.trim();
    final regex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!regex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
    String? value,
    String passwordValue,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordValue) {
      return 'Passwords do not match';
    }
    return null;
  }
}
