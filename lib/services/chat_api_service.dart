import 'package:dio/dio.dart';
import '../domain/entities/chat_message.dart';
import 'api_client.dart';

/// Chat API Service - handles all chat-related API endpoints
class ChatApiService {
  static ChatApiService? _instance;
  final ApiClient _apiClient;

  ChatApiService._(this._apiClient);

  factory ChatApiService(ApiClient apiClient) {
    _instance ??= ChatApiService._(apiClient);
    return _instance!;
  }

  /// Get chats (messages + pagination)
  /// GET /agent/chats
  /// Response: { "success": true, "data": { "messages": [...], "pagination": {...} } }
  Future<PaginatedChatResponse> getChats({
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _apiClient.get(
      '/agent/chats',
      queryParameters: <String, dynamic>{'page': page, 'per_page': perPage},
    );
    final json = response.data as Map<String, dynamic>;
    return PaginatedChatResponse.fromJson(json);
  }

  /// Send a chat message
  /// POST /agent/chat/send
  Future<ChatMessage> sendMessage({
    required String role,
    required int bookingId,
    required String message,
    String? senderType,
    int? senderId,
  }) async {
    try {
      final data = {
        'booking_id': bookingId,
        'message': message,
        if (senderType != null) 'sender_type': senderType,
        if (senderId != null) 'sender_id': senderId,
      };

      final response = await _apiClient.post('/$role/chat/send', data: data);
      final responseData = response.data as Map<String, dynamic>;
      // API returns { "success": true, "data": { ...message object }, "message": "Message sent successfully" }
      final messageJson = responseData['data'] as Map<String, dynamic>? ??
          (responseData['message'] is Map<String, dynamic> ? responseData['message'] as Map<String, dynamic> : null) ??
          responseData;
      return ChatMessage.fromJson(messageJson);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to send message',
        );
      }
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get messages for a booking/chat
  /// GET /agent/chat/{chatId}/messages
  Future<List<ChatMessage>> getMessages({
    required String role,
    required int chatId,
  }) async {
    try {
      final response = await _apiClient.get('/$role/chat/$chatId/messages');
      final data = response.data as Map<String, dynamic>;

      final dynamic messagesList = data['messages'] ?? data['data'];

      if (messagesList is List) {
        return messagesList
            .map(
              (json) => ChatMessage.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get messages');
      }
      throw Exception('Failed to get messages: $e');
    }
  }

  /// Get unread bookings
  /// GET /agent/chat/unread-bookings
  Future<List<Map<String, dynamic>>> getUnreadBookings({
    required String role,
  }) async {
    try {
      final response = await _apiClient.get('/$role/chat/unread-bookings');
      final data = response.data as Map<String, dynamic>;
      if (data['bookings'] != null) {
        return List<Map<String, dynamic>>.from(data['bookings']);
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to get unread bookings',
        );
      }
      throw Exception('Failed to get unread bookings: $e');
    }
  }

  /// Mark as Read
  /// POST /agent/chat/{chatId}/mark-read
  Future<void> markAsRead({
    required String role,
    required int chatId,
  }) async {
    try {
      await _apiClient.post('/$role/chat/$chatId/mark-read');
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to mark as read',
        );
      }
      throw Exception('Failed to mark as read: $e');
    }
  }
}
