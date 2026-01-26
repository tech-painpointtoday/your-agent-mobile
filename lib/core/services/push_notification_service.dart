import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'local_notification_service.dart';

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
      // Request permissions (iOS)
      await _requestPermissions();

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        debugPrint('FCM Token: $_fcmToken');
        onTokenReceived(_fcmToken!);
        // TODO: Send token to your backend
        // await _sendTokenToBackend(_fcmToken!);
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
        final notificationId = message.data['notificationId'];
        if (notificationId != null) {
          onNotificationTap(notificationId);
        }
      });

      // Check if app was opened from a terminated state via notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        final notificationId = initialMessage.data['notificationId'];
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
    if (notification == null) return;

    // Show local notification
    await _localNotifications.showNotification(
      id: message.hashCode,
      title: notification.title ?? 'New Notification',
      body: notification.body ?? '',
      payload: message.data['notificationId'],
    );
  }

  /// TODO: Send FCM token to your backend
  Future<void> _sendTokenToBackend(String token) async {
    // Example:
    // await http.post(
    //   Uri.parse('https://your-api.com/api/users/fcm-token'),
    //   headers: {'Authorization': 'Bearer $authToken'},
    //   body: json.encode({
    //     'token': token,
    //     'platform': Platform.isIOS ? 'ios' : 'android',
    //   }),
    // );
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
