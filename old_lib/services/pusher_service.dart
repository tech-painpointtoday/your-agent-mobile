import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:youragent/domain/entities/chat_message.dart';

/// Pusher Service - manages Pusher Channels connections for real-time chat
/// Following: https://pusher.com/docs/channels/getting_started/flutter/
class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  // Pusher credentials
  static const String _key = "8b5f1c5a3f5cc60e7979";
  static const String _cluster = "ap1";

  bool _isInitialized = false;
  bool _isConnected = false;

  // Channel subscriptions
  final Map<String, dynamic> _channels = {};

  // Event listeners
  final Map<String, StreamSubscription> _subscriptions = {};

  // Message stream controllers
  final Map<String, StreamController<ChatMessage>> _messageControllers = {};

  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;

  /// Initialize Pusher connection
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Pusher already initialized');
      return;
    }

    try {
      // For web platform, ensure Pusher JS is loaded
      // The script tag should be in web/index.html
      await pusher.init(
        apiKey: _key,
        cluster: _cluster,
        onConnectionStateChange: _onConnectionStateChange,
        onError: _onError,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onEvent: _onEvent,
        onSubscriptionError: _onSubscriptionError,
        onDecryptionFailure: _onDecryptionFailure,
        onMemberAdded: _onMemberAdded,
        onMemberRemoved: _onMemberRemoved,
      );

      await pusher.connect();
      _isInitialized = true;
      _isConnected = true;
      debugPrint('✅ Pusher initialized and connected');
    } catch (e) {
      debugPrint('❌ Error initializing Pusher: $e');
      // Don't rethrow - allow app to continue without Pusher
      // The chat will still work via API polling if needed
      debugPrint('⚠️ Continuing without Pusher real-time updates');
    }
  }

  /// Subscribe to booking chat channel
  /// Channel: chat.booking.{booking_id}
  Stream<ChatMessage> subscribeToBookingChat(int bookingId) {
    final channelName = 'chat.booking.$bookingId';

    // Return existing stream if already subscribed
    if (_messageControllers.containsKey(channelName)) {
      return _messageControllers[channelName]!.stream;
    }

    // Create new stream controller
    final controller = StreamController<ChatMessage>.broadcast();
    _messageControllers[channelName] = controller;

    // Subscribe to channel
    _subscribeToChannel(channelName);

    return controller.stream;
  }

  /// Subscribe to staff chat channel
  /// Channel: chat.staff.{conversation_id}
  Stream<ChatMessage> subscribeToStaffChat(int conversationId) {
    final channelName = 'chat.staff.$conversationId';

    // Return existing stream if already subscribed
    if (_messageControllers.containsKey(channelName)) {
      return _messageControllers[channelName]!.stream;
    }

    // Create new stream controller
    final controller = StreamController<ChatMessage>.broadcast();
    _messageControllers[channelName] = controller;

    // Subscribe to channel
    _subscribeToChannel(channelName);

    return controller.stream;
  }

  /// Internal method to subscribe to a channel
  Future<void> _subscribeToChannel(String channelName) async {
    if (_channels.containsKey(channelName)) {
      debugPrint('Already subscribed to $channelName');
      return;
    }

    try {
      await pusher.subscribe(
        channelName: channelName,
        onEvent: (event) {
          debugPrint('Event received on $channelName: ${event.eventName}');
        },
      );

      _channels[channelName] = true; // Mark as subscribed
      debugPrint('✅ Subscribed to channel: $channelName');
    } catch (e) {
      debugPrint('❌ Error subscribing to $channelName: $e');
      rethrow;
    }
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribeFromChannel(String channelName) async {
    try {
      await pusher.unsubscribe(channelName: channelName);
      _channels.remove(channelName);

      // Close and remove stream controller
      _messageControllers[channelName]?.close();
      _messageControllers.remove(channelName);

      // Cancel subscription
      _subscriptions[channelName]?.cancel();
      _subscriptions.remove(channelName);

      debugPrint('✅ Unsubscribed from channel: $channelName');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from $channelName: $e');
    }
  }

  /// Unsubscribe from booking chat
  Future<void> unsubscribeFromBookingChat(int bookingId) async {
    final channelName = 'chat.booking.$bookingId';
    await unsubscribeFromChannel(channelName);
  }

  /// Unsubscribe from staff chat
  Future<void> unsubscribeFromStaffChat(int conversationId) async {
    final channelName = 'chat.staff.$conversationId';
    await unsubscribeFromChannel(channelName);
  }

  /// Handle connection state changes
  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    debugPrint('Connection state changed: $previousState -> $currentState');
    _isConnected = currentState == 'CONNECTED';
  }

  /// Handle errors
  void _onError(String message, int? code, dynamic e) {
    debugPrint('❌ Pusher error: $message (code: $code)');
  }

  /// Handle subscription succeeded
  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    debugPrint('✅ Subscription succeeded: $channelName');
  }

  /// Handle events
  void _onEvent(PusherEvent event) {
    debugPrint('Event received: ${event.eventName} on ${event.channelName}');

    // Handle new-message event
    if (event.eventName == 'new-message') {
      try {
        final messageData = event.data;
        final chatMessage = _parseChatMessage(messageData);

        // Emit message to appropriate stream
        final channelName = event.channelName;
        if (_messageControllers.containsKey(channelName)) {
          _messageControllers[channelName]!.add(chatMessage);
        }
      } catch (e) {
        debugPrint('❌ Error parsing chat message: $e');
      }
    }
  }

  /// Parse chat message from event data
  ChatMessage _parseChatMessage(dynamic data) {
    // Handle both string and Map formats
    Map<String, dynamic> messageMap;

    if (data is String) {
      // Try to parse as JSON string
      try {
        // For now, create a mock message from string
        // In production, you'd parse the JSON properly
        messageMap = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'message': data,
          'sender_type': 'buyer',
          'sender_id': 1,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        };
      } catch (e) {
        throw Exception('Failed to parse message data: $e');
      }
    } else if (data is Map) {
      messageMap = Map<String, dynamic>.from(data);
    } else {
      throw Exception('Invalid message data format');
    }

    return ChatMessage.fromJson(messageMap);
  }

  /// Handle subscription errors
  void _onSubscriptionError(String message, dynamic e) {
    debugPrint('❌ Subscription error: $message');
  }

  /// Handle decryption failures
  void _onDecryptionFailure(String event, String reason) {
    debugPrint('❌ Decryption failure: $event - $reason');
  }

  /// Handle member added
  void _onMemberAdded(String channelName, PusherMember member) {
    debugPrint('Member added to $channelName: ${member.userId}');
  }

  /// Handle member removed
  void _onMemberRemoved(String channelName, PusherMember member) {
    debugPrint('Member removed from $channelName: ${member.userId}');
  }

  /// Disconnect from Pusher
  Future<void> disconnect() async {
    try {
      // Unsubscribe from all channels
      for (final channelName in _channels.keys.toList()) {
        await unsubscribeFromChannel(channelName);
      }

      await pusher.disconnect();
      _isConnected = false;
      _isInitialized = false;
      debugPrint('✅ Disconnected from Pusher');
    } catch (e) {
      debugPrint('❌ Error disconnecting from Pusher: $e');
    }
  }
}
