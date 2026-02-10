import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/user.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
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
      if (event.bookingId == -1) {
        // Mocking Staff/Support conversation
        final mockMessages = [
          ChatMessage(
            id: 1,
            senderType: SenderType.staff,
            senderId: 0,
            message:
                'สวัสดีครับ คุณ Agent ยินดีต้อนรับสู่ YourAgent support ครับ',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 2,
            senderType: SenderType.staff,
            senderId: 0,
            message: 'มีอะไรให้เราช่วยดูแลในวันนี้ไหมครับ?',
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
          ChatMessage(
            id: 3,
            senderType: SenderType.staff,
            senderId: 0,
            message:
                'https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=800&q=80',
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
        ];
        emit(MessageLoaded(messages: mockMessages));
        return;
      }

      final authRepo = DependencyInjection.authRepository;
      final role = authRepo.currentRole == UserRole.agent ? 'agent' : 'agency';

      // Load initial messages
      final messages = await DependencyInjection.chatApiService.getMessages(
        role: role,
        chatId: event.bookingId,
      );

      emit(MessageLoaded(messages: messages));

      // Pusher Subscription
      _currentChannel = isStaff
          ? "chat.staff.${event.bookingId}"
          : "chat.booking.${event.bookingId}";
      DependencyInjection.pusherService.subscribe(
        channelName: _currentChannel!,
        onEvent: (event) {
          if (event is PusherEvent && event.eventName == 'new-message') {
            try {
              final data = jsonDecode(event.data);
              add(NewMessageReceived(data));
            } catch (e) {
              // Ignore parse errors
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
    if (currentState is MessageLoaded) {
      try {
        final Map<String, dynamic> rawMsg =
            event.messageData['message'] ?? event.messageData;
        final newMessage = ChatMessage.fromJson(rawMsg);

        // Prevent duplicates
        if (currentState.messages.any((m) => m.id == newMessage.id)) return;

        final updatedMessages = List<ChatMessage>.from(currentState.messages)
          ..add(newMessage);
        emit(currentState.copyWith(messages: updatedMessages));
      } catch (e) {
        // Log or handle error
      }
    }
  }
}
