import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<ChatMessage> messages;
  final bool isSending;

  const MessageLoaded({required this.messages, this.isSending = false});

  MessageLoaded copyWith({List<ChatMessage>? messages, bool? isSending}) {
    return MessageLoaded(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [messages, isSending];
}

class MessageError extends MessageState {
  final String message;
  const MessageError(this.message);

  @override
  List<Object?> get props => [message];
}
