import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessageEvent {
  final int bookingId;
  const LoadMessages(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
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
