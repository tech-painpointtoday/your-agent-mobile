import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'local_notification_service.dart';
import '../di/dependency_injection.dart';
import 'device_service.dart';

/// Service for handling Firebase Cloud Messaging (Push Notifications)
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotifications =
      LocalNotificationService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase and FCM
  Future<void> initialize({
    required Function(String notificationId) onNotificationTap,
    required Function(String token) onTokenReceived,
  }) async {
    try {
      await _localNotifications.initialize(
        onNotificationTap: (payload) {
          if (payload != null && payload.isNotEmpty) {
            onNotificationTap(payload);
          }
        },
      );

      // Request permissions (iOS)
      await _requestPermissions();
      await _localNotifications.requestPermissions();
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      if (Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        int retryCount = 0;
        while (apnsToken == null && retryCount < 5) {
          debugPrint('APNS Token ยังไม่มา รอก่อน... (retry ${retryCount + 1})');
          await Future<void>.delayed(const Duration(seconds: 1));
          apnsToken = await _messaging.getAPNSToken();
          retryCount++;
        }
      }

      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        debugPrint('FCM Token: $_fcmToken');
        onTokenReceived(_fcmToken!);

        // Ensure device is registered with backend if authenticated
        if (DependencyInjection.authRepository.isAuthenticated) {
          DeviceService().registerDevice();
        }
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token refreshed: $newToken');
        onTokenReceived(newToken);
        // TODO: Send new token to backend
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message: ${message.notification?.title}');
        _handleForegroundMessage(message);
      });

      // Handle notification taps when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification tapped: ${message.data}');
        final notificationId = _extractNotificationPayload(message);
        if (notificationId != null) {
          onNotificationTap(notificationId);
        }
      });

      // Check if app was opened from a terminated state via notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        final notificationId = _extractNotificationPayload(initialMessage);
        if (notificationId != null) {
          onNotificationTap(notificationId);
        }
      }
    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  /// Handle messages when app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    // Show local notification
    await _localNotifications.showNotification(
      id: message.hashCode,
      title: title ?? 'New Notification',
      body: body ?? '',
      payload: _extractNotificationPayload(message),
    );
  }

  String? _extractNotificationPayload(RemoteMessage message) {
    final notificationId = message.data['notificationId']?.toString();
    if (notificationId != null && notificationId.isNotEmpty) {
      return notificationId;
    }

    final route = message.data['route']?.toString();
    if (route != null && route.isNotEmpty) {
      return route;
    }

    return null;
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}

/// Background message handler (must be top-level function)
/// Add this to your main.dart before runApp()
/// FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
  // Handle background message here
}
