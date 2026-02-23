import 'package:equatable/equatable.dart';
import 'pagination.dart';

/// ChatMessage entity matching the old Laravel ChatMessage model
enum SenderType {
  buyer,
  agent,
  seller,
  staff,
}

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
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int?,
      bookingId: json['booking_id'] as int?,
      staffConversationId: json['staff_conversation_id'] as int?,
      senderType: _parseSenderType(json['sender_type']),
      senderId: json['sender_id'] as int,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      senderName: json['sender_name'] as String?,
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
      messageList =
          rawData['messages'] is List<dynamic>
              ? rawData['messages'] as List<dynamic>
              : <dynamic>[];
      paginationJson =
          rawData['pagination'] is Map<String, dynamic>
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
