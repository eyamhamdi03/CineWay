import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../repository/notification_repository.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  
  List<AppNotification> _notifications = [];
  List<AppNotification> _todayNotifications = [];
  List<AppNotification> _earlierNotifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get todayNotifications => _todayNotifications;
  List<AppNotification> get earlierNotifications => _earlierNotifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load notifications from backend
  Future<void> loadNotifications(String token, {int skip = 0, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _notifications = await _repository.getNotifications(token, skip: skip, limit: limit);
      _categorizeNotifications();
      await _loadUnreadCount(token);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _notifications = [];
      _todayNotifications = [];
      _earlierNotifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load unread count
  Future<void> _loadUnreadCount(String token) async {
    try {
      _unreadCount = await _repository.getUnreadCount(token);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }
  
  /// Get unread count
  Future<int> getUnreadCount(String token) async {
    try {
      return await _repository.getUnreadCount(token);
    } catch (e) {
      _error = e.toString();
      return 0;
    }
  }
  
  /// Mark notification as read
  Future<void> markAsRead(String token, int notificationId) async {
    try {
      await _repository.markAsRead(token, notificationId);
      
      // Update local list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          timestamp: _notifications[index].timestamp,
          movieOrCinemaName: _notifications[index].movieOrCinemaName,
          icon: _notifications[index].icon,
        );
      }
      
      _categorizeNotifications();
      await _loadUnreadCount(token);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
  
  /// Mark all as read
  Future<void> markAllAsRead(String token) async {
    try {
      await _repository.markAllAsRead(token);
      
      // Update local list
      _notifications = _notifications
          .map((n) => AppNotification(
                id: n.id,
                title: n.title,
                message: n.message,
                type: n.type,
                isRead: true,
                timestamp: n.timestamp,
                movieOrCinemaName: n.movieOrCinemaName,
                icon: n.icon,
              ))
          .toList();
      
      _categorizeNotifications();
      _unreadCount = 0;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
  
  /// Delete notification
  Future<void> deleteNotification(String token, int notificationId) async {
    try {
      await _repository.deleteNotification(token, notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      _categorizeNotifications();
      await _loadUnreadCount(token);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
  
  /// Clear all notifications
  Future<void> clearAll(String token) async {
    try {
      await _repository.clearAll(token);
      _notifications = [];
      _todayNotifications = [];
      _earlierNotifications = [];
      _unreadCount = 0;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
  
  /// Categorize notifications by date
  void _categorizeNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _todayNotifications = _notifications
        .where((n) {
          final nDate = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
          return nDate == today;
        })
        .toList();
    
    _earlierNotifications = _notifications
        .where((n) {
          final nDate = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
          return nDate != today;
        })
        .toList();
  }
}
