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
}
