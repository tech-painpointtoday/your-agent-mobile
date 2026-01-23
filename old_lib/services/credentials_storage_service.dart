import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Service for storing and retrieving saved login credentials
/// Uses FlutterSecureStorage for secure storage (encrypted on device)
class CredentialsStorageService {
  static final CredentialsStorageService _instance =
      CredentialsStorageService._internal();
  factory CredentialsStorageService() => _instance;
  CredentialsStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _emailKey = 'saved_email';
  static const String _rememberMeKey = 'remember_me_enabled';

  /// Save email only (password is never stored for security)
  Future<void> saveCredentials({
    required String email,
    String? password, // Ignored - password is never stored
  }) async {
    try {
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _rememberMeKey, value: 'true');
      debugPrint('✅ Email saved securely (password not stored)');
    } catch (e) {
      debugPrint('❌ Error saving credentials: $e');
    }
  }

  /// Get saved email
  Future<String?> getSavedEmail() async {
    try {
      return await _storage.read(key: _emailKey);
    } catch (e) {
      debugPrint('❌ Error reading saved email: $e');
      return null;
    }
  }

  /// Get saved password - DEPRECATED: Password is never stored
  /// This method is kept for backward compatibility but always returns null
  @Deprecated('Password is never stored. Use getSavedEmail() instead.')
  Future<String?> getSavedPassword() async {
    // Password is never stored for security reasons
    return null;
  }

  /// Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    try {
      final value = await _storage.read(key: _rememberMeKey);
      return value == 'true';
    } catch (e) {
      debugPrint('❌ Error checking remember me status: $e');
      return false;
    }
  }

  /// Clear saved credentials
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _rememberMeKey);
      // Also clear any old password key if it exists (cleanup)
      await _storage.delete(key: 'saved_password');
      debugPrint('✅ Credentials cleared');
    } catch (e) {
      debugPrint('❌ Error clearing credentials: $e');
    }
  }

  /// Get all saved credentials (email only, password never stored)
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final email = await getSavedEmail();
      final rememberMe = await isRememberMeEnabled();

      return {
        'email': email,
        'password': null, // Password is never stored
        'rememberMe': rememberMe.toString(),
      };
    } catch (e) {
      debugPrint('❌ Error getting saved credentials: $e');
      return {'email': null, 'password': null, 'rememberMe': 'false'};
    }
  }
}
