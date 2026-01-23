import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/data/repositories/auth_repository_impl.dart';

/// App initializer following the official Google Sign-In example pattern
/// https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in/example/lib/main.dart
class AppInitializer {
  static Future<void> initialize() async {
    // Initialize Facebook SDK for web
    if (kIsWeb) {
      try {
        await FacebookAuth.i.webAndDesktopInitialize(
          appId: "1895881494619021",
          cookie: true,
          xfbml: true,
          version: "v15.0",
        );
      } catch (e) {
        debugPrint('Error initializing Facebook SDK: $e');
      }
    }

    // Initialize Google Sign-In for all platforms
    // Following the official example: initialize before any other method is called
      try {
        final authRepository = DependencyInjection.authRepository;
        if (authRepository is AuthRepositoryImpl) {
        // For web, we need to provide clientId
        // For mobile, clientId is optional (can be configured in platform-specific files)
          await authRepository.initializeGoogleSignIn(
          clientId: kIsWeb
              ? "199835057334-0sh9s5l3mee1d0qqiat0jv43e7i355bu.apps.googleusercontent.com"
              : null, // Mobile uses platform-specific configuration
            serverClientId: null, // Set if you need server-side verification
          );
        }
      } catch (e) {
        debugPrint('Error initializing Google Sign-In: $e');
    }
  }
}
