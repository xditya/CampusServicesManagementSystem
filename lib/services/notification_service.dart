import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> sendPrintCompletedNotification(
      String userEmail, String processName) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'print_status_channel',
        'Print Status',
        channelDescription: 'Notifications about print status changes',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _localNotifications.show(
        0,
        'Print Request Completed',
        'Your print request "$processName" has been completed',
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> sendLabPermissionNotification(
    String status,
    String lab,
  ) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'lab_permission_channel',
        'Lab Permission Status',
        channelDescription: 'Notifications about lab permission status changes',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      final title = 'Lab Permission ${status.toUpperCase()}';
      final body = 'Your lab permission request for $lab has been $status';

      await _localNotifications.show(
        1, // Different ID from print notifications
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error sending lab permission notification: $e');
    }
  }

  // Optional: Generic method to handle different notification types
  Future<void> handleWebSocketNotification(Map<String, dynamic> data) async {
    try {
      final type = data['data']['type'] as String?;

      switch (type) {
        case 'lab_permission':
          await sendLabPermissionNotification(
            data['data']['status'],
            data['body'].toString().split(' for ')[1].split(' has been ')[0],
          );
          break;
        case 'print_status':
          await sendPrintCompletedNotification(
            data['email'],
            data['data']['processName'],
          );
          break;
        default:
          debugPrint('Unknown notification type: $type');
      }
    } catch (e) {
      debugPrint('Error handling websocket notification: $e');
    }
  }
}
