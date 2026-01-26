import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

/// Implementation of NotificationRepository
/// This is where you switch between mock and real API
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({NotificationRemoteDataSource? remoteDataSource})
    : remoteDataSource = remoteDataSource ?? NotificationRemoteDataSource();

  @override
  Future<NotificationPage> getNotifications({
    int page = 1,
    int limit = 10,
    String filter = 'all',
  }) async {
    try {
      return await remoteDataSource.getNotifications(
        page: page,
        limit: limit,
        filter: filter,
      );
    } catch (e) {
      // TODO: Add error handling and logging
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
    } catch (e) {
      // TODO: Add error handling
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
    } catch (e) {
      // TODO: Add error handling
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
    } catch (e) {
      // TODO: Add error handling
      rethrow;
    }
  }

  @override
  Future<void> archiveNotification(String notificationId) async {
    try {
      await remoteDataSource.archiveNotification(notificationId);
    } catch (e) {
      // TODO: Add error handling
      rethrow;
    }
  }
}
