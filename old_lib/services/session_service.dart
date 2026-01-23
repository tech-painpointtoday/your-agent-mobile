import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Session Service - handles session timeout and activity tracking
/// Automatically logs out users after 7 days of inactivity
class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _lastActivityKey = 'last_activity_timestamp';
  static const Duration _sessionTimeout = Duration(days: 7);

  /// Update last activity timestamp to current time
  Future<void> updateActivity() async {
    try {
      final now = DateTime.now().toIso8601String();
      await _storage.write(key: _lastActivityKey, value: now);
      debugPrint('📅 Session activity updated: $now');
    } catch (e) {
      debugPrint('Error updating session activity: $e');
    }
  }

  /// Get last activity timestamp
  Future<DateTime?> getLastActivity() async {
    try {
      final timestamp = await _storage.read(key: _lastActivityKey);
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
      return null;
    } catch (e) {
      debugPrint('Error reading last activity: $e');
      return null;
    }
  }

  /// Check if session is still valid (within 7 days)
  Future<bool> isSessionValid() async {
    try {
      final lastActivity = await getLastActivity();
      if (lastActivity == null) {
        // No activity recorded, consider session invalid
        return false;
      }

      final now = DateTime.now();
      final difference = now.difference(lastActivity);

      final isValid = difference < _sessionTimeout;
      
      if (!isValid) {
        debugPrint('⏰ Session expired. Last activity: $lastActivity, Difference: ${difference.inDays} days');
      } else {
        debugPrint('✅ Session valid. Last activity: $lastActivity, Days remaining: ${(_sessionTimeout.inDays - difference.inDays)}');
      }

      return isValid;
    } catch (e) {
      debugPrint('Error checking session validity: $e');
      return false;
    }
  }

  /// Clear session data (on logout)
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _lastActivityKey);
      debugPrint('🗑️ Session cleared');
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  /// Initialize session (call after successful login)
  Future<void> initializeSession() async {
    await updateActivity();
  }

  /// Get days until session expires
  Future<int?> getDaysUntilExpiry() async {
    try {
      final lastActivity = await getLastActivity();
      if (lastActivity == null) return null;

      final now = DateTime.now();
      final difference = now.difference(lastActivity);
      final daysRemaining = _sessionTimeout.inDays - difference.inDays;

      return daysRemaining > 0 ? daysRemaining : 0;
    } catch (e) {
      debugPrint('Error calculating days until expiry: $e');
      return null;
    }
  }
}

