import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../helper/config.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketChannel? _channel;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isConnected = false;
  bool _isReconnecting = false;
  static const maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  WebSocketService._internal();

  Future<void> connect() async {
    if (_isConnected || _isReconnecting) return;

    try {
      // Check network connectivity first
      try {
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          debugPrint('No network connectivity');
          _setupConnectivityListener();
          return;
        }
      } catch (e) {
        debugPrint('Error checking connectivity: $e');
        // Continue anyway as the connectivity check might fail on some devices
      }

      _isReconnecting = true;
      debugPrint('Attempting to connect to WebSocket...');

      _channel = WebSocketChannel.connect(
        Uri.parse(NOTIF_WEBSOCKET),
      );

      _isConnected = true;
      _isReconnecting = false;
      _reconnectAttempts = 0;
      _listen();
      _setupConnectivityListener();
      debugPrint('WebSocket connected successfully');
    } catch (e) {
      _isReconnecting = false;
      debugPrint('WebSocket connection error: $e');
      _reconnect();
    }
  }

  void _listen() {
    _channel?.stream.listen(
      (message) async {
        try {
          String jsonStr = message.toString();
          if (jsonStr.startsWith('Broadcast: ')) {
            jsonStr = jsonStr.substring('Broadcast: '.length);
          }

          final data = json.decode(jsonStr);
          final session = await account.get();

          // Handle print notifications
          if (data['type'] == 'print_completed' &&
              session.email == data['userEmail']) {
            await _showNotification(
              'Print Request Completed',
              data['message'] ?? 'Your print request has been completed',
              'print_status_channel',
              'Print Status',
              'Notifications about print status changes',
            );
          }

          // Handle gate pass notifications
          if (data['type'] == 'gate_pass_update' &&
              session.email == data['userEmail']) {
            final status = data['status'];
            final passData = data['data'];

            String title = 'Gate Pass ${status.toUpperCase()}';
            String message = status == 'approved'
                ? 'Your gate pass for ${passData['date']} has been approved'
                : 'Your gate pass for ${passData['date']} has been rejected by ${passData['updatedBy']}';

            await _showNotification(
              title,
              message,
              'gate_pass_channel',
              'Gate Pass Status',
              'Notifications about gate pass status changes',
            );
          }

          // Handle pink slip notifications
          if (data['type'] == 'pink_slip_update' &&
              session.email == data['userEmail']) {
            final status = data['status'];
            final slipData = data['data'];

            String title = 'Pink Slip ${status.toUpperCase()}';
            String message = status == 'approved'
                ? 'Your pink slip for ${slipData['date']} has been approved'
                : 'Your pink slip for ${slipData['date']} has been rejected by ${slipData['updatedBy']}';

            await _showNotification(
              title,
              message,
              'pink_slip_channel',
              'Pink Slip Status',
              'Notifications about pink slip status changes',
            );
          }

          // Handle lab permission notifications
          if (data['type'] == 'lab_permission_update' &&
              session.email == data['userEmail']) {
            final status = data['status'];
            final permissionData = data['data'];

            String title = 'Lab Permission ${status.toUpperCase()}';
            String message =
                'Your lab permission request for ${permissionData['lab']} has been $status';

            await _showNotification(
              title,
              message,
              'lab_permission_channel',
              'Lab Permission Status',
              'Notifications about lab permission status changes',
            );
          }

          // Handle leave form notifications
          if (data['type'] == 'leave_form_update' &&
              session.email == data['userEmail']) {
            final status = data['status'];
            final formData = data['data'];

            String title = 'Leave Form ${status.toUpperCase()}';
            String message = status == 'approved'
                ? 'Your leave application for ${formData['dateFrom']} to ${formData['dateTo']} has been approved'
                : 'Your leave application for ${formData['dateFrom']} to ${formData['dateTo']} has been rejected by ${formData['updatedBy']}';

            await _showNotification(
              title,
              message,
              'leave_form_channel',
              'Leave Form Status',
              'Notifications about leave form status changes',
            );
          }

          // Handle ID card request notifications
          if (data['type'] == 'id_card_update' &&
              session.email == data['userEmail']) {
            final status = data['status'];
            final cardData = data['data'];

            String title = 'ID Card Request ${status.toUpperCase()}';
            String message = status == 'accepted'
                ? 'Your ID card request has been approved'
                : 'Your ID card request has been rejected by ${cardData['updatedBy']}';

            await _showNotification(
              title,
              message,
              'id_card_channel',
              'ID Card Status',
              'Notifications about ID card request status changes',
            );
          }

          // Handle 3D print request notifications
          if (data['type'] == '3d_print_update' &&
              session.email == data['userEmail']) {
            final status = data['status'];
            final printData = data['data'];
            final comment = printData['comment'];

            String title = '3D Print Request ${status.toUpperCase()}';
            String message = status == 'approved'
                ? 'Your print request for ${printData['fileName']} has been approved'
                : 'Your print request for ${printData['fileName']} has been rejected';

            if (comment != null && comment.isNotEmpty) {
              message += '\nComment: $comment';
            }

            await _showNotification(
              title,
              message,
              '3d_print_channel',
              '3D Print Status',
              'Notifications about 3D print request status changes',
            );
          }

          // Handle vehicle pass notifications
          if (data['type'] == 'vehicle_pass_update' &&
              session.email == data['userEmail']) {
            final status = data['status'];
            final passData = data['data'];

            await _showNotification(
              'Vehicle Pass ${status.toUpperCase()}',
              'Your vehicle pass request for ${passData['vehicleNumber']} at ${passData['time']} has been $status',
              'vehicle_pass_channel',
              'Vehicle Pass Status',
              'Notifications about vehicle pass status changes',
            );
          }
        } catch (e) {
          debugPrint('Error handling WebSocket message: $e');
          debugPrint('Raw message: $message');
        }
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
        _reconnect();
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
        _isConnected = false;
        _reconnect();
      },
      cancelOnError: false,
    );
  }

  // Helper method to show notifications
  Future<void> _showNotification(
    String title,
    String body,
    String channelId,
    String channelName,
    String channelDescription,
  ) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      const iOSDetails = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond, // Use timestamp for unique ID
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  void _reconnect() {
    if (_isReconnecting || _reconnectAttempts >= maxReconnectAttempts) return;

    _isConnected = false;
    _reconnectAttempts++;
    debugPrint(
        'Attempting to reconnect ($_reconnectAttempts/$maxReconnectAttempts)...');

    Future.delayed(Duration(seconds: _reconnectAttempts * 5), () {
      connect();
    });
  }

  void disconnect() {
    _connectivitySubscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _isReconnecting = false;
    _reconnectAttempts = 0;
  }

  void sendMessage(String message) {
    if (!_isConnected) {
      debugPrint('Cannot send message: WebSocket not connected');
      return;
    }
    try {
      _channel?.sink.add(message);
      // debugPrint('Sent WebSocket message: $message');
    } catch (e) {
      debugPrint('Error sending WebSocket message: $e');
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && !_isConnected) {
        debugPrint('Network connectivity restored, attempting to reconnect...');
        _reconnectAttempts = 0;
        connect();
      }
    });
  }
}
