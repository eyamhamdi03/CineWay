import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  /// Request notification permissions from the user
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if notification permission is granted
  static Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Open app settings to allow user to manually enable notifications
  static Future<void> openNotificationSettings() async {
    await openAppSettings();
  }

  /// Get current notification permission status
  static Future<PermissionStatus> getNotificationStatus() async {
    return await Permission.notification.status;
  }

  /// Request permission with dialog explanation
  static Future<bool> requestNotificationPermissionWithDialog(BuildContext context) async {
    final isDenied = await Permission.notification.isDenied;
    
    if (isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    
    // If permanently denied, show dialog
    final isPermanentlyDenied = await Permission.notification.isDenied;
    if (isPermanentlyDenied) {
      if (context.mounted) {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Notification Permission',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Enable notifications to stay updated about your bookings, new releases, and special offers.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Now'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context, true);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ) ?? false;
      }
    }
    
    return false;
  }

  /// Shows a permission denied snackbar
  static void showPermissionDeniedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification permission is required to see updates'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => openAppSettings(),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
