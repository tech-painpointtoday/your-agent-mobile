#!/bin/bash
# build android dev flavor AAB
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
flutter build appbundle --flavor dev -t lib/main_dev.dart $BUILD_ARGS

# Rename the output AAB
if [ -f "build/app/outputs/bundle/devRelease/app-dev-release.aab" ]; then
  mv "build/app/outputs/bundle/devRelease/app-dev-release.aab" "build/app/outputs/bundle/devRelease/yourhome_dev_v${VERSION_SAFE}.aab"
  echo "Renamed to build/app/outputs/bundle/devRelease/yourhome_dev_v${VERSION_SAFE}.aab"
elif [ -f "build/app/outputs/bundle/devDebug/app-dev-debug.aab" ]; then
  mv "build/app/outputs/bundle/devDebug/app-dev-debug.aab" "build/app/outputs/bundle/devDebug/yourhome_dev_debug_v${VERSION_SAFE}.aab"
  echo "Renamed to build/app/outputs/bundle/devDebug/yourhome_dev_debug_v${VERSION_SAFE}.aab"
else
  echo "AAB file not found"
fi
