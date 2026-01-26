import 'package:youragent/features/notifications/models/notification_model.dart';

/// Repository interface for notification operations
/// This defines the contract that any notification data source must implement
abstract class NotificationRepository {
  /// Fetch notifications with pagination
  /// [page] - Page number to fetch (starts from 1)
  /// [limit] - Number of notifications per page
  /// [filter] - Filter type ('all', 'unread', 'archived')
  Future<NotificationPage> getNotifications({
    int page = 1,
    int limit = 10,
    String filter = 'all',
  });

  /// Mark a specific notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);

  /// Toggle archive status of a notification
  Future<void> archiveNotification(String notificationId);
}

/// Response model for paginated notifications
class NotificationPage {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  NotificationPage({
    required this.notifications,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    return NotificationPage(
      notifications: (json['notifications'] as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList(),
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }
}
