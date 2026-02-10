import 'package:equatable/equatable.dart';

class ChatBooking extends Equatable {
  final int id;
  final String participantName;
  final String? lastMessage;
  final int unreadCount;
  final DateTime? lastActiveAt;
  final String? avatarUrl;

  const ChatBooking({
    required this.id,
    required this.participantName,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastActiveAt,
    this.avatarUrl,
  });

  factory ChatBooking.fromJson(Map<String, dynamic> json) {
    // Handling possible variations in API response
    final user = json['user'] as Map<String, dynamic>?;
    final lastMsg = json['last_message'] as Map<String, dynamic>?;

    return ChatBooking(
      id: json['id'] as int,
      participantName:
          user?['name'] as String? ??
          json['participant_name'] as String? ??
          'Unknown',
      lastMessage:
          lastMsg?['message'] as String? ??
          json['last_message_text'] as String?,
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
