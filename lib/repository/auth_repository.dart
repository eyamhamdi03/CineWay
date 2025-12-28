import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  /// Sign up a new user
  /// Returns user data on success, throws exception on failure
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Sign up failed');
      }
    } catch (e) {
      throw Exception('Sign up error: $e');
    }
  }

  /// Sign in with email and password
  /// Returns access token and user data on success
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Invalid credentials');
      }
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
  }

  /// Verify email token (for email verification)
  Future<bool> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Email verification error: $e');
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Password reset request error: $e');
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'new_password': newPassword}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Password reset error: $e');
    }
  }
}
