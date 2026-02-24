import 'package:equatable/equatable.dart';

class ChatBooking extends Equatable {
  final int id;
  final String participantName;
  final String? lastMessage;
  final String? participantPhone;
  final int unreadCount;
  final DateTime? lastActiveAt;
  final String? avatarUrl;

  const ChatBooking({
    required this.id,
    required this.participantName,
    this.participantPhone,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastActiveAt,
    this.avatarUrl,
  });

  factory ChatBooking.fromJson(Map<String, dynamic> json) {
    // Handling possible variations in API response
    final user = json['user'] as Map<String, dynamic>?;
    final lastMsg = json['last_message'] as Map<String, dynamic>?;
    final messageText =
        lastMsg?['message'] as String? ??
        json['last_message_text'] as String? ??
        '';
    final imageUrl =
        lastMsg?['image_url'] as String? ??
        json['last_message_image_url'] as String?;

    String finalMessage = messageText;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final senderType = (lastMsg?['sender_type'] ?? json['sender_type'])
          ?.toString()
          .toLowerCase();
      if (senderType == 'agent' || senderType == 'staff') {
        finalMessage = "You: sent an image";
      } else {
        finalMessage = "Have an image message";
      }
    }

    return ChatBooking(
      id: json['id'] as int,
      participantName:
          user?['name'] as String? ??
          json['participant_name'] as String? ??
          'Unknown',
      participantPhone: user?['phone'] as String?,
      lastMessage: finalMessage,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastActiveAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : (json['last_active_at'] != null
                ? DateTime.parse(json['last_active_at'])
                : null),
      avatarUrl:
          user?['profile_photo'] as String? ?? json['avatar_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    participantName,
    lastMessage,
    unreadCount,
    lastActiveAt,
    avatarUrl,
  ];
}
