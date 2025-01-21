import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initializationSettings);
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> sendPrintCompletedNotification(
      String userEmail, String processName) async {
    try {
      // In a real app, you would store FCM tokens in your database
      // and use your server to send notifications via Firebase Admin SDK

      // For now, we'll show a local notification
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
      print('Error sending notification: $e');
    }
  }
}
