import 'package:equatable/equatable.dart';
import 'pagination.dart';

/// ChatMessage entity matching the old Laravel ChatMessage model
enum SenderType { buyer, agent, seller, staff }

class ChatMessage extends Equatable {
  final int? id;
  final int? bookingId;
  final int? staffConversationId;
  final SenderType senderType;
  final int senderId;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? senderName; // Computed attribute
  final String? imageUrl;

  const ChatMessage({
    this.id,
    this.bookingId,
    this.staffConversationId,
    required this.senderType,
    required this.senderId,
    required this.message,
    this.isRead = false,
    this.readAt,
    this.createdAt,
    this.updatedAt,
    this.senderName,
    this.imageUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // If we're parsing a conversation object that has a nested 'last_message'
    final lastMsg = json['last_message'] as Map<String, dynamic>?;
    final effectiveJson = lastMsg ?? json;

    return ChatMessage(
      id: json['id'] as int?,
      bookingId:
          json['booking_id'] as int? ??
          (lastMsg != null ? json['id'] as int? : null),
      staffConversationId: json['staff_conversation_id'] as int?,
      senderType: _parseSenderType(effectiveJson['sender_type']),
      senderId: (effectiveJson['sender_id'] as num? ?? 0).toInt(),
      message:
          (effectiveJson['message'] ?? effectiveJson['last_message_text'] ?? '')
              .toString(),
      isRead: (effectiveJson['is_read'] ?? json['unread_count'] == 0) as bool,
      readAt: effectiveJson['read_at'] != null
          ? DateTime.parse(effectiveJson['read_at'])
          : null,
      createdAt: (effectiveJson['created_at'] ?? json['updated_at']) != null
          ? DateTime.parse((effectiveJson['created_at'] ?? json['updated_at']))
          : null,
      updatedAt: effectiveJson['updated_at'] != null
          ? DateTime.parse(effectiveJson['updated_at'])
          : null,
      senderName:
          json['sender_name'] as String? ??
          (json['user'] as Map?)?['name'] as String?,
      imageUrl: effectiveJson['image_url'] as String?,
    );
  }

  static SenderType _parseSenderType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'buyer':
          return SenderType.buyer;
        case 'agent':
          return SenderType.agent;
        case 'seller':
          return SenderType.seller;
        case 'staff':
          return SenderType.staff;
        default:
          return SenderType.buyer;
      }
    }
    return SenderType.buyer;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'staff_conversation_id': staffConversationId,
      'sender_type': senderType.name,
      'sender_id': senderId,
      'message': message,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sender_name': senderName,
      'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    staffConversationId,
    senderType,
    senderId,
    message,
    isRead,
    readAt,
    createdAt,
    updatedAt,
    senderName,
    imageUrl,
  ];
}

/// Response from GET /agent/chats: { "data": { "messages": [...], "pagination": {...} } }
class PaginatedChatResponse extends Equatable {
  final List<ChatMessage> messages;
  final Pagination pagination;

  const PaginatedChatResponse({
    required this.messages,
    required this.pagination,
  });

  factory PaginatedChatResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<dynamic> messageList;
    Map<String, dynamic> paginationJson;
    if (rawData is Map<String, dynamic>) {
      messageList = rawData['messages'] is List<dynamic>
          ? rawData['messages'] as List<dynamic>
          : <dynamic>[];
      paginationJson = rawData['pagination'] is Map<String, dynamic>
          ? rawData['pagination'] as Map<String, dynamic>
          : <String, dynamic>{};
    } else {
      messageList = <dynamic>[];
      paginationJson = <String, dynamic>{};
    }
    return PaginatedChatResponse(
      messages: messageList
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(paginationJson),
    );
  }

  @override
  List<Object?> get props => [messages, pagination];
}
