#!/bin/bash
# build dev flavor
# Extract version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
# Replace + with _ for filename safety
VERSION_SAFE=${VERSION//+/_}

echo "Building version: $VERSION"


BUILD_ARGS=""

# Parse arguments
for arg in "$@"
do
    if [ "$arg" == "-r" ]; then
        BUILD_ARGS="--release"
        echo "Release mode enabled"
    fi
done

flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run --flavor dev -t lib/main_dev.dart $BUILD_ARGS