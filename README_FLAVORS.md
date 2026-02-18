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

## Non-production behavior

- **In-app banner**: When running **dev** or **staging** (any build type), a small "DEV" or "STAGING" banner is shown at the top of the app so you can tell the environment at a glance. Production builds do not show any banner.
- **App icon per flavor**: Dev and staging use different app (launcher) icons:
  - **Android**: Icons are copied from `assets/logo/app_icon_dev.png` (dev) and `assets/logo/app_icon_uat.png` (staging) during build via Gradle (see `android/app/build.gradle.kts`).
  - **iOS**: The **dev** scheme uses `AppIcon-Dev` (from `assets/logo/app_icon_dev.png`); **staging** uses `AppIcon-Staging` (from `assets/logo/app_icon_uat.png`). Asset sets live in `ios/Runner/Assets.xcassets/`. To regenerate all icon sizes from the source PNGs, run: `./scripts/ios_generate_flavor_icons.sh` (requires macOS `sips` or ImageMagick). If you add a staging build configuration for Runner in Xcode, set `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-Staging` for that configuration.
