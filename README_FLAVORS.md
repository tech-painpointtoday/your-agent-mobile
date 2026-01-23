# Running the App with Flavors

## Android (uses `--flavor`)

```bash
# Dev
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Prod
flutter run --flavor prod -t lib/main_prod.dart
```

## iOS (use entry points directly, no `--flavor`)

iOS doesn't support `--flavor` the same way Android does. Instead, use the entry points directly:

```bash
# Dev
flutter run -t lib/main_dev.dart

# Staging
flutter run -t lib/main_staging.dart

# Prod
flutter run -t lib/main_prod.dart
```

## Building APK/IPA

### Android APK
```bash
# Dev
flutter build apk --flavor dev -t lib/main_dev.dart

# Staging
flutter build apk --flavor staging -t lib/main_staging.dart

# Prod
flutter build apk --flavor prod -t lib/main_prod.dart
```

### iOS IPA (use entry points)
```bash
# Dev
flutter build ios -t lib/main_dev.dart --release

# Staging
flutter build ios -t lib/main_staging.dart --release

# Prod
flutter build ios -t lib/main_prod.dart --release
```

## Alternative: Using `--dart-define` (works for both platforms)

You can also use the default entry point with `--dart-define`:

```bash
# Dev
flutter run --dart-define=FLAVOR=dev -t lib/main.dart

# Staging
flutter run --dart-define=FLAVOR=staging -t lib/main.dart

# Prod
flutter run --dart-define=FLAVOR=prod -t lib/main.dart
```
