import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static PusherService? _instance;
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  PusherService._();

  factory PusherService() {
    _instance ??= PusherService._();
    return _instance!;
  }

  Future<void> init() async {
    try {
      await _pusher.init(
        apiKey: "8b5f1c5a3f5cc60e7979",
        cluster: "ap1",
        onConnectionStateChange: (currentState, previousState) {
          debugPrint(
            "Pusher Connection State changed from $previousState to $currentState",
          );
        },
        onError: (message, code, dynamic e) {
          debugPrint("Pusher Error: $message (code: $code) - $e");
        },
        onSubscriptionSucceeded: (channelName, data) {
          debugPrint("Pusher Subscribed to $channelName");
        },
      );
      await _pusher.connect();
    } catch (e) {
      debugPrint("Pusher Initialization Error: $e");
    }
  }

  Future<void> subscribe({
    required String channelName,
    required Function(dynamic event) onEvent,
  }) async {
    try {
      await _pusher.subscribe(channelName: channelName, onEvent: onEvent);
      debugPrint("Pusher Subscribing to $channelName");
    } catch (e) {
      debugPrint("Pusher Subscribe Error ($channelName): $e");
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
