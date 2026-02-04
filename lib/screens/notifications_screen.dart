import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
import '../models/notification.dart';
import '../viewmodel/session/session_viewmodel.dart';
import '../viewmodel/notifications_viewmodel.dart';
import '../services/notification_permission_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationsViewModel();
    _loadNotifications();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final isGranted = await NotificationPermissionService.requestNotificationPermission();
    if (!isGranted && mounted) {
      // Permission was denied
      await NotificationPermissionService.requestNotificationPermissionWithDialog(context);
    }
  }

  void _loadNotifications() {
    final session = context.read<SessionViewModel>();
    if (session.accessToken != null && session.accessToken!.isNotEmpty) {
      _viewModel.loadNotifications(session.accessToken!);
    }
  }

  String _getTimeString(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (nDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
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
        child: ChangeNotifierProvider<NotificationsViewModel>(
          create: (_) => _viewModel,
          child: Consumer<NotificationsViewModel>(
            builder: (context, viewModel, _) {
              return Column(
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
                        PopupMenuButton<String>(
                          color: const Color(0xFF1E1E1E),
                          onSelected: (String choice) async {
                            if (choice == 'permissions') {
                              final isGranted = await NotificationPermissionService.requestNotificationPermission();
                              if (!isGranted && mounted) {
                                await NotificationPermissionService.requestNotificationPermissionWithDialog(context);
                              }
                            } else if (choice == 'clear') {
                              final session = context.read<SessionViewModel>();
                              if (session.accessToken != null) {
                                await viewModel.clearAll(session.accessToken!);
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'permissions',
                              child: Row(
                                children: [
                                  Icon(Icons.notifications_active, color: Colors.white, size: 18),
                                  SizedBox(width: 12),
                                  Text(
                                    'Enable Notifications',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            if (viewModel.notifications.isNotEmpty)
                              const PopupMenuDivider(),
                            if (viewModel.notifications.isNotEmpty)
                              const PopupMenuItem<String>(
                                value: 'clear',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_sweep, color: Colors.red, size: 18),
                                    SizedBox(width: 12),
                                    Text(
                                      'Clear All',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Notifications List
                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : viewModel.error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error: ${viewModel.error}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadNotifications,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : viewModel.notifications.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.notifications_none, color: Colors.white30, size: 64),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No notifications',
                                          style: TextStyle(color: Colors.white70, fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Enable notifications to stay updated',
                                          style: TextStyle(color: Colors.white54, fontSize: 12),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final isGranted = await NotificationPermissionService.requestNotificationPermission();
                                            if (!isGranted && mounted) {
                                              await NotificationPermissionService.requestNotificationPermissionWithDialog(context);
                                            } else if (isGranted && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Notifications enabled!')),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.notifications_active),
                                          label: const Text('Enable Notifications'),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    children: [
                                      // Notification Status Card
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.dodgerBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.dodgerBlue.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: AppColors.dodgerBlue,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Notification History',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${viewModel.notifications.length} notifications • ${viewModel.notifications.where((n) => !n.isRead).length} unread',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.6),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // TODAY Section
                                      if (viewModel.todayNotifications.isNotEmpty) ...[
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
                                        ...viewModel.todayNotifications
                                            .map((notification) => _buildNotificationCard(context, notification, viewModel))
                                            .toList(),
                                        const SizedBox(height: 24),
                                      ],

                                      // EARLIER Section
                                      if (viewModel.earlierNotifications.isNotEmpty) ...[
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
                                        ...viewModel.earlierNotifications
                                            .map((notification) => _buildNotificationCard(context, notification, viewModel))
                                            .toList(),
                                      ],
                                    ],
                                  ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification notification, NotificationsViewModel viewModel) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            color: const Color(0xFF1E1E1E),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.check, color: Colors.white),
                  title: const Text('Mark as read', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    final session = context.read<SessionViewModel>();
                    if (session.accessToken != null) {
                      viewModel.markAsRead(session.accessToken!, notification.id);
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    final session = context.read<SessionViewModel>();
                    if (session.accessToken != null) {
                      viewModel.deleteNotification(session.accessToken!, notification.id);
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
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