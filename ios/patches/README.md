# iOS Pusher plugin patch (EXC_BREAKPOINT in subscribe)

## Problem

`pusher_channels_flutter` (iOS pod 0.0.1) can crash with **EXC_BREAKPOINT (SIGTRAP)** in `SwiftPusherChannelsFlutterPlugin.subscribe` when:

1. **`pusher` is nil** – e.g. `.subscribe()` is called before `init()`/`connect()` finish or init failed.
2. **`call.arguments` is nil or wrong type** – force cast `as! [String: String]` crashes.
3. **`channelName` is missing** – `args["channelName"]!` force-unwrap crashes.

## Fix

`SwiftPusherChannelsFlutterPlugin.swift` in this folder is a **safe** version that:

- Uses **optional** `pusher: Pusher?` and `methodChannel: FlutterMethodChannel?` (no implicit unwraps).
- Uses **guard let** / **if let** for `call.arguments` and `args["channelName"]` (and other keys where needed).
- Returns **FlutterError** to Dart (with codes like `NOT_INITIALIZED`, `INVALID_ARGS`) instead of crashing.

## How to apply

**Option A – Apply into pub-cache (run after each `flutter pub get`):**

```bash
# From project root
./scripts/apply_pusher_ios_patch.sh
```

**Option B – Manual copy:**

Copy this folder’s `SwiftPusherChannelsFlutterPlugin.swift` over the plugin’s iOS class file:

- **macOS pub-cache:**  
  `~/.pub-cache/hosted/pub.dev/pusher_channels_flutter-2.4.0/ios/Classes/SwiftPusherChannelsFlutterPlugin.swift`

Then run `flutter clean` and rebuild the iOS app.

## Dart-side handling

After applying the patch, the plugin may return errors instead of crashing. Handle them in your Pusher service, e.g.:

```dart
try {
  await _pusher.subscribe(channelName: channelName, onEvent: onEvent);
} on PlatformException catch (e) {
  if (e.code == 'NOT_INITIALIZED') {
    // Retry after init/connect
  }
  if (e.code == 'INVALID_ARGS') {
    // channelName missing or invalid
  }
}
```

Ensure you **await** `init()` and `connect()` before calling `subscribe()`.
