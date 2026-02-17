#!/bin/bash
# Run prod flavor

flutter clean
flutter pub get
flutter run  --flavor prod -t lib/main_prod.dart "$@"
