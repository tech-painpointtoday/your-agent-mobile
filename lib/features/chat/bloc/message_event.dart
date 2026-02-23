import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessageEvent {
  /// For booking chat: same as channel chat.booking.{bookingId}.
  /// For staff chat: when [conversationId] is set, channel is chat.staff.{conversationId}.
  final int bookingId;
  /// Optional. For staff support channel (chat.staff.{conversation_id}). If null, staff uses [bookingId].
  final int? conversationId;
  const LoadMessages(this.bookingId, {this.conversationId});

  @override
  List<Object?> get props => [bookingId, conversationId];
}

class SendMessage extends MessageEvent {
  final int bookingId;
  final String message;
  const SendMessage({required this.bookingId, required this.message});

  @override
  List<Object?> get props => [bookingId, message];
}

class MarkAsRead extends MessageEvent {
  final int bookingId;
  const MarkAsRead(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class NewMessageReceived extends MessageEvent {
  final Map<String, dynamic> messageData;
  const NewMessageReceived(this.messageData);

  @override
  List<Object?> get props => [messageData];
}
