import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_data_service.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/widgets/app_loader.dart';
import 'package:youragent/domain/entities/chat_message.dart';
import 'package:youragent/services/pusher_service.dart';
import 'package:youragent/core/di/dependency_injection.dart' as di;
import 'package:youragent/domain/entities/user.dart';

/// Chat Detail Screen - shows chat messages for a booking with real-time updates via Pusher
class ChatDetailScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final int bookingId;
  final int? conversationId; // For staff chats

  const ChatDetailScreen({
    super.key,
    required this.changeLocale,
    required this.bookingId,
    this.conversationId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  StreamSubscription<ChatMessage>? _messageSubscription;
  bool _isLoading = false;
  bool _isSending = false;
  UserRole? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);

    try {
      // Get current user role
      final authRepo = di.DependencyInjection.authRepository;
      _currentUserRole = authRepo.currentRole;

      // Load initial messages
      await _loadMessages();

      // Initialize Pusher if not already initialized
      final pusherService = PusherService();
      if (!pusherService.isInitialized) {
        await pusherService.initialize();
      }

      // Subscribe to real-time messages
      Stream<ChatMessage> messageStream;
      if (widget.conversationId != null) {
        // Staff chat
        messageStream = pusherService.subscribeToStaffChat(
          widget.conversationId!,
        );
      } else {
        // Booking chat
        messageStream = pusherService.subscribeToBookingChat(widget.bookingId);
      }

      _messageSubscription = messageStream.listen(
        (message) {
          setState(() {
            _messages.add(message);
          });
          _scrollToBottom();
        },
        onError: (error) {
          debugPrint('Error receiving message: $error');
        },
      );

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error initializing chat: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    try {
      final chatApiService = di.DependencyInjection.chatApiService;
      final authRepo = di.DependencyInjection.authRepository;
      final role = authRepo.currentRole;

      if (role == null) return;

      String roleStr;
      switch (role) {
        case UserRole.agent:
          roleStr = 'agent';
          break;
        case UserRole.agency:
          roleStr = 'agency';
          break;
      }

      final messages = await chatApiService.getMessages(
        role: roleStr,
        chatId: widget.bookingId,
      );

      setState(() {
        _messages.clear();
        _messages.addAll(messages);
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      // Fallback to mock data
      final mockData = MockDataService();
      setState(() {
        _messages.addAll(
          mockData.getMockChatMessages(bookingId: widget.bookingId),
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final chatApiService = di.DependencyInjection.chatApiService;
      final authRepo = di.DependencyInjection.authRepository;
      final role = authRepo.currentRole;
      final user = authRepo.currentUser;

      if (role == null || user == null) {
        throw Exception('User not authenticated');
      }

      String roleStr;
      String senderType;
      int senderId;

      switch (role) {
        case UserRole.agent:
          roleStr = 'agent';
          senderType = 'agent';
          senderId = int.tryParse(user.id ?? '0') ?? 0;
          break;
        case UserRole.agency:
          roleStr = 'agency';
          senderType = 'agency';
          senderId = int.tryParse(user.id ?? '0') ?? 0;
          break;
      }

      final newMessage = await chatApiService.sendMessage(
        role: roleStr,
        bookingId: widget.bookingId,
        message: messageText,
        senderType: senderType,
        senderId: senderId,
      );

      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.wildSand,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(changeLocale: widget.changeLocale),
            Expanded(
              child: Column(
                children: [
                  // Messages list
                  Expanded(
                    child: _isLoading
                        ? const AppLoader()
                        : _messages.isEmpty
                        ? Center(
                            child: Text(
                              'No messages yet',
                              style: GoogleFonts.anuphan(
                                fontSize: 14,
                                color: AppColors.shadyLady,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isMe = _isMyMessage(message);
                              return _buildMessageBubble(message, isMe);
                            },
                          ),
                  ),
                  // Input area
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                        top: BorderSide(color: AppColors.bonJour, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: AppColors.bonJour,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _isSending
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: _sendMessage,
                                icon: const Icon(
                                  Icons.send,
                                  color: AppColors.jungleGreen,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.jungleGreen
                                      .withValues(alpha: 0.1),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // const Footer(),
          ],
        ),
      ),
    );
  }

  bool _isMyMessage(ChatMessage message) {
    if (_currentUserRole == null) return false;

    switch (_currentUserRole) {
      case UserRole.agent:
        return message.senderType == SenderType.agent;
      case UserRole.agency:
        // Agency users use the same sender type as agent in chat
        return message.senderType == SenderType.agent;
      case null:
        return false;
    }
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isMe ? AppColors.jungleGreen : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isMe
              ? null
              : Border.all(color: AppColors.bonJour, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName ?? 'Unknown',
              style: GoogleFonts.anuphan(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isMe ? AppColors.white : AppColors.shadyLady,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.message,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: isMe ? AppColors.white : AppColors.baseDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
