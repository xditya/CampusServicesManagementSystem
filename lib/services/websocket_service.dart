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
          // debugPrint('Received WebSocket message: $jsonStr');

          final data = json.decode(jsonStr);
          if (data['type'] == 'print_completed') {
            try {
              final session = await account.get();
              if (session.email == data['userEmail']) {
                const androidDetails = AndroidNotificationDetails(
                  'print_status_channel',
                  'Print Status',
                  channelDescription:
                      'Notifications about print status changes',
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
                  data['message'] ?? 'Your print request has been completed',
                  notificationDetails,
                );
              }
            } catch (e) {
              debugPrint('Error getting session or showing notification: $e');
            }
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

  void _reconnect() {
    if (_isReconnecting || _reconnectAttempts >= maxReconnectAttempts) return;

    _isConnected = false;
    _reconnectAttempts++;
    debugPrint(
        'Attempting to reconnect (${_reconnectAttempts}/$maxReconnectAttempts)...');

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
