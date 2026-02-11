#!/bin/bash
# Run dev flavor

flutter clean
flutter pub get
flutter run  --flavor dev -t lib/main_dev.dart "$@"
