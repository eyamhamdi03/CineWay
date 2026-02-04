import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/notification.dart';

class NotificationRepository {
  final String _baseUrl = ApiConfig.baseUrl;

  /// Get all notifications for the current user
  Future<List<AppNotification>> getNotifications(String token, {int skip = 0, int limit = 20, bool? isRead}) async {
    try {
      final uri = Uri.parse('$_baseUrl/notifications/')
          .replace(queryParameters: {
            'skip': skip.toString(),
            'limit': limit.toString(),
            if (isRead != null) 'is_read': isRead.toString(),
          });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unread_count'] ?? 0;
      } else {
        throw Exception('Failed to load unread count');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific notification
  Future<AppNotification> getNotification(String token, int notificationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return AppNotification.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Notification not found');
      } else {
        throw Exception('Failed to load notification');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<AppNotification> markAsRead(String token, int notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'is_read': true,
        }),
      );

      if (response.statusCode == 200) {
        return AppNotification.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/mark-all-as-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String token, int notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all notifications
  Future<void> clearAll(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/clear-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to clear notifications');
      }
    } catch (e) {
      rethrow;
    }
  }
}
