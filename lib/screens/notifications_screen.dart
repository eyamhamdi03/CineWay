import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications;
  late List<AppNotification> _todayNotifications;
  late List<AppNotification> _earlierNotifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notifications = [
      AppNotification(
        id: '1',
        title: 'Booking Successful!',
        message: 'Your ticket for Galaxy Runners is ready. Enjoy your movie!',
        type: 'booking',
        isRead: false,
        timestamp: DateTime.now(),
        movieOrCinemaName: 'Galaxy Runners',
        icon: 'confirmation_number',
      ),
      AppNotification(
        id: '2',
        title: 'Rate your experience',
        message: 'How was Final Stand? Share your thoughts with the community.',
        type: 'rating',
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        movieOrCinemaName: 'Final Stand',
        icon: 'star',
      ),
      AppNotification(
        id: '3',
        title: 'New Movie Release',
        message: 'The trailer for Cosmic Journey is now available to watch.',
        type: 'movie_release',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        movieOrCinemaName: 'Cosmic Journey',
        icon: 'notifications',
      ),
      AppNotification(
        id: '4',
        title: 'Weekend Promo!',
        message: 'Get 20% off on snacks with your next booking using code CINE20.',
        type: 'promo',
        isRead: true,
        timestamp: DateTime(2023, 10, 12),
        icon: 'celebration',
      ),
      AppNotification(
        id: '5',
        title: 'Payment Receipt',
        message: 'Your payment of \$24.00 was successful for Order #CW-8821.',
        type: 'payment',
        isRead: true,
        timestamp: DateTime(2023, 10, 11),
        icon: 'receipt_long',
      ),
    ];

    _categorizeNotifications();
  }

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

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification = AppNotification(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          isRead: true,
          timestamp: notification.timestamp,
          movieOrCinemaName: notification.movieOrCinemaName,
          icon: notification.icon,
        );
      }
      _categorizeNotifications();
    });
  }

  String _getTimeString(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (nDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} AM';
    } else if (nDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(timestamp.month)} ${timestamp.day}, ${timestamp.year}';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'booking':
        return AppColors.dodgerBlue;
      case 'rating':
        return const Color(0xFFFFD700);
      default:
        return Colors.white.withOpacity(0.3);
    }
  }

  Color _getIconBackgroundColor(String type) {
    switch (type) {
      case 'booking':
        return AppColors.dodgerBlue.withOpacity(0.15);
      case 'rating':
        return const Color(0xFFFFD700).withOpacity(0.15);
      default:
        return Colors.white.withOpacity(0.05);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text(
                      'Mark all as read',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dodgerBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notifications List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // TODAY Section
                  if (_todayNotifications.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
                      child: Text(
                        'TODAY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ..._todayNotifications.map((notification) => _buildNotificationCard(notification)).toList(),
                    const SizedBox(height: 24),
                  ],

                  // EARLIER Section
                  if (_earlierNotifications.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'EARLIER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ..._earlierNotifications.map((notification) => _buildNotificationCard(notification)).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return GestureDetector(
      onTap: () {
        // TODO: Handle notification tap
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? const Color(0xFF1E1E1E).withOpacity(0.5) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(notification.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForType(notification.type),
                      color: _getIconColor(notification.type),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.4,
                          ),
                          children: [
                            if (notification.movieOrCinemaName != null && 
                                notification.message.contains(notification.movieOrCinemaName!)) ...[
                              TextSpan(
                                text: notification.message.split(notification.movieOrCinemaName!).first,
                              ),
                              TextSpan(
                                text: notification.movieOrCinemaName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: notification.message.split(notification.movieOrCinemaName!).last,
                              ),
                            ] else
                              TextSpan(text: notification.message),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getTimeString(notification.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Unread Indicator
            if (!notification.isRead)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.dodgerBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'booking':
        return Icons.confirmation_number;
      case 'rating':
        return Icons.star;
      case 'movie_release':
        return Icons.notifications;
      case 'promo':
        return Icons.celebration;
      case 'payment':
        return Icons.receipt_long;
      default:
        return Icons.notifications;
    }
  }
}
