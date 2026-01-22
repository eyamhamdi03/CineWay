import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class UserRepository {
  final String baseUrl = ApiConfig.baseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> updateMe({
    required String token,
    String? fullName,
    String? email,
    DateTime? dateOfBirth,
  }) async {
    final uri = Uri.parse("$baseUrl/users/me");
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (email != null) body['email'] = email;
    if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth.toIso8601String();

    final resp = await http.put(uri, headers: _headers(token), body: jsonEncode(body));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to update profile: ${resp.statusCode} ${resp.body}');
  }

  Future<Map<String, dynamic>> updatePreferences({
    required String token,
    bool? notificationsEnabled,
    bool? darkMode,
    bool? newsletterSubscribed,
  }) async {
    final uri = Uri.parse("$baseUrl/users/me/preferences");
    final body = <String, dynamic>{};
    if (notificationsEnabled != null) body['notifications_enabled'] = notificationsEnabled;
    if (darkMode != null) body['dark_mode'] = darkMode;
    if (newsletterSubscribed != null) body['newsletter_subscribed'] = newsletterSubscribed;

    final resp = await http.put(uri, headers: _headers(token), body: jsonEncode(body));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to update preferences: ${resp.statusCode} ${resp.body}');
  }

  Future<String?> uploadProfilePicture({
    required String token,
    required File file,
  }) async {
    final uri = Uri.parse("$baseUrl/users/me/profile-picture");
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final m = jsonDecode(resp.body) as Map<String, dynamic>;
      return m['profile_picture_url']?.toString();
    }
    throw HttpException('Failed to upload profile picture: ${resp.statusCode} ${resp.body}');
  }
}
