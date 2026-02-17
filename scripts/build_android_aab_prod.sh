#!/bin/bash
# build android prod flavor
# Extract version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
# Replace + with _ for filename safety
VERSION_SAFE=${VERSION//+/_}

echo "Building version: $VERSION"

flutter clean
flutter pub get
flutter build appbundle --flavor prod -t lib/main_prod.dart

# Rename the output AAB
if [ -f "build/app/outputs/bundle/prodRelease/app-prod-release.aab" ]; then
  mv "build/app/outputs/bundle/prodRelease/app-prod-release.aab" "build/app/outputs/bundle/prodRelease/youragent_prod_v${VERSION_SAFE}.aab"
  echo "Renamed to build/app/outputs/bundle/prodRelease/youragent_prod_v${VERSION_SAFE}.aab"
else
  echo "AAB file not found at build/app/outputs/bundle/prodRelease/"
fi
