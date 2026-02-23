import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../core/config/app_config.dart';

/// Pusher channel and event names for chat.
/// - Booking chat (buyer ↔ seller/agent): chat.booking.{booking_id}, event "new-message"
/// - Staff support (staff ↔ buyer/seller/agent): chat.staff.{conversation_id}, event "new-message"
abstract class PusherChannels {
  static String chatBookingChannel(int bookingId) => 'chat.booking.$bookingId';
  static String chatStaffChannel(int conversationId) =>
      'chat.staff.$conversationId';
  static const String newMessageEvent = 'new-message';
}

class PusherService {
  static PusherService? _instance;
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  /// Ensures init runs once and subscribe always waits for it.
  Future<void>? _initFuture;

  PusherService._();

  factory PusherService() {
    _instance ??= PusherService._();
    return _instance!;
  }

  Future<void> init() async {
    if (_initFuture != null) return _initFuture;
    _initFuture = _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    try {
      debugPrint(
        "Pusher init: key=${AppConfig.pusherKey}, cluster=${AppConfig.pusherCluster}",
      );
      await _pusher.init(
        apiKey: AppConfig.pusherKey,
        cluster: AppConfig.pusherCluster,
        onConnectionStateChange: (currentState, previousState) {
          debugPrint(
            "[onConnectionStateChange] Pusher Connection State changed from $previousState to $currentState",
          );
        },
        onError: (message, code, dynamic e) {
          debugPrint("[onError] Pusher Error: $message (code: $code) - $e");
        },
        onSubscriptionSucceeded: (channelName, data) {
          debugPrint(
            "[onSubscriptionSucceeded] Pusher Subscribed to $channelName",
          );
        },
      );
      await _pusher.connect();
      debugPrint("Pusher connect() completed");
    } catch (e) {
      debugPrint("Pusher Initialization Error: $e");
      _initFuture = null;
      rethrow;
    }
  }

  Future<void> subscribe({
    required String channelName,
    required Function(dynamic event) onEvent,
  }) async {
    try {
      await (_initFuture ?? init());
      await _pusher.subscribe(channelName: channelName, onEvent: onEvent);
      debugPrint("Pusher Subscribing to $channelName");
    } on PlatformException catch (e) {
      debugPrint(
        "Pusher Subscribe PlatformException ($channelName): ${e.code} - ${e.message}",
      );
      if (e.code == 'NOT_INITIALIZED') {
        await init();
        try {
          await _pusher.subscribe(channelName: channelName, onEvent: onEvent);
          debugPrint("Pusher Subscribing to $channelName (after init)");
        } catch (e2) {
          debugPrint("Pusher Subscribe Error ($channelName): $e2");
        }
      } else {
        rethrow;
      }
    } catch (e) {
      debugPrint("Pusher Subscribe Error ($channelName): $e");
      rethrow;
    }
  }

  Future<void> unsubscribe(String channelName) async {
    try {
      await _pusher.unsubscribe(channelName: channelName);
      debugPrint("Pusher Unsubscribed from $channelName");
    } catch (e) {
      debugPrint("Pusher Unsubscribe Error ($channelName): $e");
    }
  }

  void disconnect() {
    _pusher.disconnect();
  }
}
