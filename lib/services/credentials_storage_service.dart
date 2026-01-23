import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialsStorageService {
  static final CredentialsStorageService _instance =
      CredentialsStorageService._internal();
  factory CredentialsStorageService() => _instance;
  CredentialsStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _emailKey = 'saved_email';
  static const String _rememberMeKey = 'remember_me_enabled';

  Future<void> saveEmail({required String email}) async {
    try {
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _rememberMeKey, value: 'true');
    } catch (e) {
      debugPrint('Error saving email: $e');
    }
  }

  Future<String?> getSavedEmail() async {
    try {
      return _storage.read(key: _emailKey);
    } catch (e) {
      debugPrint('Error reading saved email: $e');
      return null;
    }
  }

  Future<bool> isRememberMeEnabled() async {
    try {
      final value = await _storage.read(key: _rememberMeKey);
      return value == 'true';
    } catch (e) {
      debugPrint('Error checking remember me: $e');
      return false;
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _rememberMeKey);
    } catch (e) {
      debugPrint('Error clearing saved email: $e');
    }
  }
}

