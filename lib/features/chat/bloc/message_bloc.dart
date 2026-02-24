import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/user.dart';
import '../../../services/pusher_service.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final bool isStaff;
  String? _currentChannel;

  MessageBloc({this.isStaff = false}) : super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<NewMessageReceived>(_onNewMessageReceived);
  }

  @override
  Future<void> close() async {
    if (_currentChannel != null) {
      DependencyInjection.pusherService.unsubscribe(_currentChannel!);
    }
    return super.close();
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageLoading());
    try {
      final authRepo = DependencyInjection.authRepository;
      final role = authRepo.currentRole == UserRole.agent ? 'agent' : 'agency';

      // Load initial messages
      final messages = await DependencyInjection.chatApiService.getMessages(
        role: role,
        chatId: event.bookingId,
      );

      emit(MessageLoaded(messages: messages));

      // Pusher: chat.booking.{booking_id} or chat.staff.{conversation_id}
      _currentChannel = isStaff
          ? PusherChannels.chatStaffChannel(
              event.conversationId ?? event.bookingId,
            )
          : PusherChannels.chatBookingChannel(event.bookingId);
      DependencyInjection.pusherService.subscribe(
        channelName: _currentChannel!,
        onEvent: (event) {
          debugPrint(
            "Pusher Event: ${event.eventName} on ${_currentChannel!}"
            "event: ${event.data}",
          );
          if (event is PusherEvent &&
              event.eventName == PusherChannels.newMessageEvent) {
            try {
              final dynamic raw = event.data;
              final Map<String, dynamic> data = raw is Map<String, dynamic>
                  ? raw
                  : (raw is String
                        ? Map<String, dynamic>.from(
                            jsonDecode(raw) as Map<dynamic, dynamic>,
                          )
                        : <String, dynamic>{});
              if (data.isNotEmpty) {
                add(NewMessageReceived(data));
              }
            } catch (e) {
              debugPrint("Pusher new-message parse error: $e");
            }
          }
        },
      );

      // Auto mark as read when entering the chat
      add(MarkAsRead(event.bookingId));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<MessageState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MessageLoaded) return;

    // Optimistically could be handled, but for now just send and reload
    emit(currentState.copyWith(isSending: true));

    try {
      if (event.bookingId == -1) {
        // Mock sending to Support
        await Future.delayed(const Duration(milliseconds: 800));
        final newMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch,
          senderType: SenderType.agent,
          senderId: 1,
          message: event.message,
          createdAt: DateTime.now(),
        );
        final updatedMessages = List<ChatMessage>.from(currentState.messages)
          ..add(newMessage);
        emit(MessageLoaded(messages: updatedMessages));
        return;
      }

      final authRepo = DependencyInjection.authRepository;
      final role = authRepo.currentRole == UserRole.agent ? 'agent' : 'agency';

      await DependencyInjection.chatApiService.sendMessage(
        role: role,
        bookingId: event.bookingId,
        message: event.message,
        image: event.image,
      );

      // Reload messages after sending
      final updatedMessages = await DependencyInjection.chatApiService
          .getMessages(role: role, chatId: event.bookingId);

      emit(MessageLoaded(messages: updatedMessages));
    } catch (e) {
      // Keep existing messages but show error if we had a way to toast
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<MessageState> emit,
  ) async {
    try {
      final authRepo = DependencyInjection.authRepository;
      final role = authRepo.currentRole == UserRole.agent ? 'agent' : 'agency';

      await DependencyInjection.chatApiService.markAsRead(
        role: role,
        chatId: event.bookingId,
      );
    } catch (_) {
      // Silently fail for mark as read as it's not critical for the UI flow
    }
  }

  Future<void> _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<MessageState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MessageLoaded) return;

    try {
      // Event payload: { "message": { "id", "booking_id", "sender_type", ... } }
      final rawMsg = event.messageData['message'] ?? event.messageData;
      if (rawMsg is! Map<String, dynamic>) return;

      final newMessage = ChatMessage.fromJson(rawMsg);

      if (currentState.messages.any((m) => m.id == newMessage.id)) return;

      final updatedMessages = List<ChatMessage>.from(currentState.messages)
        ..add(newMessage);
      emit(currentState.copyWith(messages: updatedMessages));
    } catch (e) {
      debugPrint("NewMessageReceived apply error: $e");
    }
  }
}
