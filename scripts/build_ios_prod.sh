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
flutter build ipa --flavor prod -t lib/main_prod.dart --export-method ad-hoc $BUILD_ARGS

# Rename the output IPA
if [ -f "build/ios/ipa/yourhome.ipa" ]; then
  mv "build/ios/ipa/yourhome.ipa" "build/ios/ipa/yourhome_prod_v${VERSION_SAFE}.ipa"
  echo "Renamed to build/ios/ipa/yourhome_prod_v${VERSION_SAFE}.ipa"
else
  echo "IPA file not found at build/ios/ipa/yourhome.ipa"
fi
