import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _lastActivityKey = 'last_activity_timestamp';
  static const Duration _sessionTimeout = Duration(days: 7);

  Future<void> updateActivity() async {
    try {
      await _storage.write(
        key: _lastActivityKey,
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error updating session activity: $e');
    }
  }

  Future<DateTime?> getLastActivity() async {
    try {
      final timestamp = await _storage.read(key: _lastActivityKey);
      if (timestamp == null) return null;
      return DateTime.parse(timestamp);
    } catch (e) {
      debugPrint('Error reading last activity: $e');
      return null;
    }
  }

  Future<bool> isSessionValid() async {
    try {
      final last = await getLastActivity();
      if (last == null) return false;
      return DateTime.now().difference(last) < _sessionTimeout;
    } catch (e) {
      debugPrint('Error checking session validity: $e');
      return false;
    }
  }

  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _lastActivityKey);
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  Future<void> initializeSession() async => updateActivity();
}

