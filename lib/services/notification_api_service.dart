import 'package:dio/dio.dart';

import 'api_client.dart';

class NotificationApiService {
  final ApiClient _apiClient;

  NotificationApiService(this._apiClient);

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/agent/notifications',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      return response.data;
    } on DioException catch (e) {
      throw e.message ?? 'Failed to fetch notifications';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.post('/agent/notifications/$id/mark-read');
    } on DioException catch (e) {
      throw e.message ?? 'Failed to mark notification as read';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.post('/agent/notifications/mark-all-read');
    } on DioException catch (e) {
      throw e.message ?? 'Failed to mark all notifications as read';
    } catch (e) {
      throw e.toString();
    }
  }
}
