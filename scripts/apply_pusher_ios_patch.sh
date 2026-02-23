#!/usr/bin/env bash
# Applies the safe SwiftPusherChannelsFlutterPlugin patch to the pusher_channels_flutter
# iOS plugin in the pub-cache. Run from project root. Run after flutter pub get if needed.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PATCH_FILE="$PROJECT_ROOT/ios/patches/SwiftPusherChannelsFlutterPlugin.swift"

if [[ ! -f "$PATCH_FILE" ]]; then
  echo "Patch file not found: $PATCH_FILE"
  exit 1
fi

# Resolve pub-cache (same logic as Flutter)
if [[ -n "$PUB_CACHE" ]]; then
  PUB_CACHE_ROOT="$PUB_CACHE"
else
  PUB_CACHE_ROOT="$HOME/.pub-cache"
fi

# Find plugin path (version may vary)
PLUGIN_DIR=$(find "$PUB_CACHE_ROOT/hosted/pub.dev" -maxdepth 1 -type d -name "pusher_channels_flutter-*" 2>/dev/null | head -1)
if [[ -z "$PLUGIN_DIR" ]]; then
  echo "pusher_channels_flutter not found in pub-cache. Run: flutter pub get"
  exit 1
fi

TARGET="$PLUGIN_DIR/ios/Classes/SwiftPusherChannelsFlutterPlugin.swift"
if [[ ! -d "$(dirname "$TARGET")" ]]; then
  echo "Plugin iOS Classes dir not found: $(dirname "$TARGET")"
  exit 1
fi

cp "$PATCH_FILE" "$TARGET"
echo "Applied patch to: $TARGET"
