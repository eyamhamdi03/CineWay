# Notification System with Permission Handling - Integration Guide

## Overview

The notification system now includes:
1. **Backend Integration** - Notifications fetched from the API
2. **Notification History** - All notifications stored and categorized by date
3. **Permission Management** - Automatic permission requests on Android and iOS
4. **Status Tracking** - Visual indicators showing notification count and unread status

## Features Implemented

### 1. Notification Permission Service
**File**: `lib/services/notification_permission_service.dart`

This service handles all permission-related operations:

```dart
// Request notification permission
final isGranted = await NotificationPermissionService.requestNotificationPermission();

// Check current permission status
final status = await NotificationPermissionService.getNotificationStatus();

// Request with dialog explanation
await NotificationPermissionService.requestNotificationPermissionWithDialog(context);

// Open app settings
await NotificationPermissionService.openNotificationSettings();
```

**Key Methods:**
- `requestNotificationPermission()` - Simple async request
- `isNotificationPermissionGranted()` - Check if permission is already granted
- `getNotificationStatus()` - Get detailed permission status
- `openNotificationSettings()` - Navigate user to app notification settings
- `requestNotificationPermissionWithDialog()` - Request with context-aware dialog
- `showPermissionDeniedSnackbar()` - Show user-friendly error message

### 2. Notification History Linking

The notification history now displays:
- **Total notification count** - Shows `X notifications`
- **Unread count** - Shows `Y unread`
- **Visual status card** - Blue info card at top of notification list
- **Date categorization**:
  - TODAY section - Shows time (HH:MM)
  - EARLIER section - Shows date (Jan 15, 2026)

Example:
```
📌 Notification History
   5 notifications • 2 unread
   
   TODAY
   └─ Your booking confirmed (14:30)
   
   EARLIER
   └─ New movie available (Jan 15)
```

### 3. Automatic Permission Request

When user opens NotificationsScreen:
1. App automatically requests notification permission
2. If denied, shows a context-aware dialog
3. User can enable from settings or try again later
4. If no notifications exist, shows enable button with explanation

### 4. Notification Management

**Header Menu Options:**
- ✅ Mark All as Read
- 🔔 Enable Notifications (requests permission)
- 🗑️ Clear All (delete all notifications)

**Long-press Actions:**
- Mark individual notification as read
- Delete individual notification

## Platform Configuration

### Android Configuration

**AndroidManifest.xml Changes:**
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Added notification permission requirement for Android 13+ (API level 33+)

**Target SDK**: Android 14+

### iOS Configuration

**Info.plist Changes:**
```xml
<key>NSUserNotificationUsageDescription</key>
<string>We would like to send you notifications about your bookings, new releases, and special offers.</string>
```

This message appears when iOS requests permission to send notifications.

## Dependencies

### New Package
```yaml
permission_handler: ^11.4.3
```

**Why permission_handler?**
- Cross-platform (Android, iOS, web)
- Handles permission request flows
- Manages settings navigation
- Provides permission status checking
- Follows platform guidelines

## How to Test

### Test Permission Request

1. **First Launch**:
   ```
   Open NotificationsScreen 
   → System shows permission dialog
   → Grant or deny permission
   ```

2. **After Denying**:
   ```
   Open NotificationsScreen again
   → App shows custom dialog
   → User can tap "Open Settings" to enable
   ```

3. **Check Status**:
   ```dart
   final isGranted = await NotificationPermissionService
       .isNotificationPermissionGranted();
   ```

### Test Notification History

1. **Load notifications**:
   - Navigate to NotificationsScreen
   - Backend loads notifications
   - History displays with count and unread badge

2. **Test categorization**:
   - TODAY notifications show time (14:30)
   - EARLIER notifications show date (Jan 15, 2026)

3. **Test interactions**:
   - Long-press to mark as read/delete
   - "Mark all as read" button updates status
   - "Clear All" removes all notifications

### Test Permission Dialog

```dart
// Trigger dialog on empty state button
ElevatedButton.icon(
  onPressed: () async {
    final isGranted = await NotificationPermissionService
        .requestNotificationPermission();
    if (!isGranted && mounted) {
      await NotificationPermissionService
          .requestNotificationPermissionWithDialog(context);
    }
  },
  icon: const Icon(Icons.notifications_active),
  label: const Text('Enable Notifications'),
),
```

## Backend Integration

The notification system queries the backend API:

**Endpoint**: `GET /api/notifications/`
**Auth**: Bearer token (from SessionViewModel)
**Response**: List of AppNotification objects

**Sample Response**:
```json
[
  {
    "id": 1,
    "user_id": 284,
    "title": "Booking Confirmed",
    "message": "Your booking for Avatar is confirmed",
    "type": "booking",
    "is_read": false,
    "timestamp": "2026-02-04T14:30:00",
    "movie_or_cinema_name": "Avatar",
    "icon": "icons/booking.png",
    "related_id": 123
  }
]
```

## Error Handling

### Permission Denied Scenarios

1. **User Taps "Not Now"**:
   - Permission not requested
   - Can retry anytime from menu

2. **User Denies Permission**:
   - App shows dialog
   - "Open Settings" navigates to app settings
   - User manually enables in system settings

3. **Permanently Denied**:
   - Dialog appears with "Open Settings" button
   - Directs user to Android/iOS notification settings

### API Error Handling

```dart
// Handled in NotificationsViewModel
- Loading state: Shows spinner
- Error state: Shows error message with retry button
- Empty state: Shows "No notifications" with enable button
- Success state: Shows categorized notifications
```

## Code Changes Summary

### Files Created
1. `lib/services/notification_permission_service.dart` - Permission handling
2. Updated `lib/screens/notifications_screen.dart` - Permission integration
3. Updated `pubspec.yaml` - Added permission_handler dependency
4. Updated `android/app/src/main/AndroidManifest.xml` - Android permission
5. Updated `ios/Runner/Info.plist` - iOS permission description

### Key Additions
```dart
// In initState
Future<void> _requestNotificationPermission() async {
  final isGranted = await NotificationPermissionService.requestNotificationPermission();
  if (!isGranted && mounted) {
    await NotificationPermissionService.requestNotificationPermissionWithDialog(context);
  }
}

// In menu
PopupMenuButton with:
- Enable Notifications option
- Clear All option

// In empty state
Button to enable notifications

// In notification list
Status card showing count and unread badges
```

## Next Steps

1. **Run `flutter pub get`** to install permission_handler
2. **Test on physical device** (emulator may not request permissions)
3. **Grant notification permission** when prompted
4. **Verify notifications appear** in the history
5. **Test all interactions** (mark as read, delete, clear all)

## Troubleshooting

### Permission dialog not showing
- Ensure device is running Android 13+ or iOS 10+
- Check that app hasn't been denied permission before
- Try: Settings → Apps → CineWay → Notifications → Enable

### Notifications not loading
- Check backend server is running
- Verify token is valid in SessionViewModel
- Check network connectivity
- Look for errors in "Error loading notifications" state

### History not updating
- Pull to refresh might help
- Check that backend notifications endpoint returns data
- Verify database has sample notifications (5 seeded)

## Permissions Summary

### Android Permissions
- `POST_NOTIFICATIONS` - Send push/local notifications (Android 13+)

### iOS Permissions  
- User Notification - Send alerts, badges, sounds

### Runtime Permissions
- Both platforms request user consent at runtime
- Permission can be managed in system settings
- App gracefully handles denied/granted states
