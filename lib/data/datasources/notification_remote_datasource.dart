import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../domain/repositories/notification_repository.dart';

/// Remote data source for notification API calls
class NotificationRemoteDataSource {
  // TODO: Replace with your actual API base URL
  static const String _baseUrl = 'https://api.youragent.example.com';

  final http.Client client;

  NotificationRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Fetch notifications from API
  Future<NotificationPage> getNotifications({
    int page = 1,
    int limit = 10,
    String filter = 'all',
  }) async {
    try {
      final response = await client.get(
        Uri.parse(
          '$_baseUrl/api/notifications?page=$page&limit=$limit&filter=$filter',
        ),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authentication header
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NotificationPage.fromJson(jsonData);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await client.put(
        Uri.parse('$_baseUrl/api/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authentication header
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await client.put(
        Uri.parse('$_baseUrl/api/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authentication header
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl/api/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authentication header
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete notification: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Archive/unarchive a notification
  Future<void> archiveNotification(String notificationId) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/notifications/$notificationId/archive'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authentication header
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to archive notification: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
