#!/bin/bash
# build android dev flavor
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
flutter build apk --flavor prod -t lib/main_prod.dart $BUILD_ARGS

# Rename the output APK
if [ -f "build/app/outputs/flutter-apk/app-prod-release.apk" ]; then
  mv "build/app/outputs/flutter-apk/app-prod-release.apk" "build/app/outputs/flutter-apk/youragent_prod_v${VERSION_SAFE}.apk"
  echo "Renamed to build/app/outputs/flutter-apk/youragent_prod_v${VERSION_SAFE}.apk"
elif [ -f "build/app/outputs/flutter-apk/app-prod-debug.apk" ]; then
  mv "build/app/outputs/flutter-apk/app-prod-debug.apk" "build/app/outputs/flutter-apk/youragent_prod_debug_v${VERSION_SAFE}.apk"
  echo "Renamed to build/app/outputs/flutter-apk/youragent_prod_debug_v${VERSION_SAFE}.apk"
else
  echo "APK file not found at build/app/outputs/flutter-apk/"
fi