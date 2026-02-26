import 'dart:io';
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
    int perPage = 10,
  }) async {
    final response = await _apiClient.get(
      '/agent/chats',
      queryParameters: <String, dynamic>{'page': page, 'per_page': perPage},
    );
    final json = response.data as Map<String, dynamic>;
    return PaginatedChatResponse.fromJson(json);
  }

  /// Get inquiry chat summaries (one per inquiry) for the conversation list.
  ///
  /// GET /agent/property-inquiries
  ///
  /// Response shape:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "inquiries": [
  ///       {
  ///         "id": 2,
  ///         "property_id": 122,
  ///         "buyer": { ... },
  ///         "agent": { ... },
  ///         "status": "open",
  ///         "messages_count": 0,
  ///         "unread_count": 0,
  ///         "latest_message": { ... } | null,
  ///         ...
  ///       }
  ///     ]
  ///   }
  /// }
  ///
  /// We map each inquiry with a non-null `latest_message` into a synthetic
  /// `ChatMessage` so that the existing grouping logic can treat it as an
  /// inquiry-type conversation. Inquiries with `latest_message == null`
  /// are **not** returned (to avoid showing empty conversations).
  Future<List<ChatMessage>> getInquiryConversations() async {
    try {
      final response = await _apiClient.get('/agent/property-inquiries');
      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final inquiries =
          (data['inquiries'] as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<String, dynamic>>();

      final result = <ChatMessage>[];

      for (final inquiry in inquiries) {
        final latest = inquiry['latest_message'];
        if (latest == null || latest is! Map<String, dynamic>) {
          // If latest_message is null, do not show this inquiry in the list.
          continue;
        }

        final buyer = inquiry['buyer'] as Map<String, dynamic>?;

        // Build a wrapper JSON compatible with ChatMessage.fromJson:
        final wrapper = <String, dynamic>{
          ...inquiry,
          // Ensure the conversation id is treated as property_inquiry_id.
          'property_inquiry_id': inquiry['id'],
          'last_message': latest,
          // Help senderName resolution for the buyer side.
          'sender_name': inquiry['sender_name'] ??
              buyer?['name'] as String? ??
              '',
          'user': buyer,
        };

        result.add(ChatMessage.fromJson(wrapper));
      }

      return result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load inquiry chats',
      );
    } catch (e) {
      throw Exception('Failed to load inquiry chats: $e');
    }
  }

  /// Send a chat message
  /// POST /agent/chat/send
  Future<ChatMessage> sendMessage({
    required String role,
    required int bookingId,
    required String message,
    String? senderType,
    int? senderId,
    File? image,
  }) async {
    try {
      dynamic data;
      if (image != null) {
        data = FormData.fromMap({
          'booking_id': bookingId,
          'message': message,
          if (senderType != null) 'sender_type': senderType,
          if (senderId != null) 'sender_id': senderId,
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        });
      } else {
        data = {
          'booking_id': bookingId,
          'message': message,
          if (senderType != null) 'sender_type': senderType,
          if (senderId != null) 'sender_id': senderId,
        };
      }

      final response = await _apiClient.post('/$role/chat/send', data: data);
      final responseData = response.data as Map<String, dynamic>;
      // API returns { "success": true, "data": { ...message object }, "message": "Message sent successfully" }
      final messageJson =
          responseData['data'] as Map<String, dynamic>? ??
          (responseData['message'] is Map<String, dynamic>
              ? responseData['message'] as Map<String, dynamic>
              : null) ??
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
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to get messages',
        );
      }
      throw Exception('Failed to get messages: $e');
    }
  }

  /// Get messages for a property inquiry chat
  /// GET /agent/property-inquiries/{inquiryId}/messages
  Future<List<ChatMessage>> getInquiryMessages({
    required int inquiryId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/agent/property-inquiries/$inquiryId/messages',
      );
      final data = response.data as Map<String, dynamic>;

      final dynamic messagesList = data['messages'] ?? data['data'];

      if (messagesList is List) {
        return messagesList
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to get inquiry messages',
        );
      }
      throw Exception('Failed to get inquiry messages: $e');
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
  Future<void> markAsRead({required String role, required int chatId}) async {
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

  /// Send a chat message for a property inquiry
  /// POST /agent/property-inquiries/{inquiryId}/send
  Future<ChatMessage> sendInquiryMessage({
    required int inquiryId,
    required String message,
    File? image,
  }) async {
    try {
      dynamic data;
      if (image != null) {
        data = FormData.fromMap({
          'message': message,
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        });
      } else {
        data = {
          'message': message,
        };
      }

      final response = await _apiClient.post(
        '/agent/property-inquiries/$inquiryId/send',
        data: data,
      );
      final responseData = response.data as Map<String, dynamic>;
      final messageJson =
          responseData['data'] as Map<String, dynamic>? ??
          (responseData['message'] is Map<String, dynamic>
              ? responseData['message'] as Map<String, dynamic>
              : null) ??
          responseData;
      return ChatMessage.fromJson(messageJson);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to send inquiry message',
        );
      }
      throw Exception('Failed to send inquiry message: $e');
    }
  }

  /// Mark inquiry as read
  /// POST /agent/property-inquiries/{inquiryId}/mark-read
  Future<void> markInquiryAsRead({required int inquiryId}) async {
    try {
      await _apiClient.post('/agent/property-inquiries/$inquiryId/mark-read');
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to mark inquiry as read',
        );
      }
      throw Exception('Failed to mark inquiry as read: $e');
    }
  }
}
