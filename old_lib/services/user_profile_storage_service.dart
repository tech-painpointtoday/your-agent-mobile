import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youragent/data/models/user_profile_model.dart';

/// Service for storing and retrieving user profile data from SharedPreferences
/// Note: On web, SharedPreferences may not be available. The service handles this gracefully
/// by skipping caching and fetching data directly from the API.
class UserProfileStorageService {
  static final UserProfileStorageService _instance =
      UserProfileStorageService._internal();
  factory UserProfileStorageService() => _instance;
  UserProfileStorageService._internal();

  static const String _profileKey = 'user_profile_data';
  SharedPreferences? _prefs;
  bool _initialized = false;
  bool _hasLoggedWarning = false; // Only log warning once

  /// Initialize SharedPreferences (call this before using other methods)
  Future<void> _ensureInitialized() async {
    if (_initialized && _prefs != null) {
      return;
    }
    
    if (_initialized && _prefs == null) {
      // Already tried and failed, don't try again
      return;
    }
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    } catch (e) {
      _initialized = true; // Mark as initialized so we don't keep trying
      _prefs = null;
      // Only log warning once to avoid spam
      if (!_hasLoggedWarning) {
        _hasLoggedWarning = true;
        debugPrint('⚠️ SharedPreferences not available (this is normal on web). Profile caching disabled.');
      }
    }
  }

  /// Save user profile data to SharedPreferences
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      await _ensureInitialized();
      if (_prefs == null) {
        // Silently skip - SharedPreferences is optional for caching
        return;
      }
      
      final profileJson = jsonEncode(profile.toJson());
      await _prefs!.setString(_profileKey, profileJson);
      if (kDebugMode) {
        debugPrint('✅ User profile cached');
      }
    } catch (e) {
      // Silently fail - SharedPreferences is optional for caching
      // Profile will be fetched from API if cache is unavailable
    }
  }

  /// Get user profile data from SharedPreferences
  Future<UserProfileModel?> getProfile() async {
    try {
      await _ensureInitialized();
      if (_prefs == null) {
        return null;
      }
      
      final profileJson = _prefs!.getString(_profileKey);
      if (profileJson == null) {
        return null;
      }
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserProfileModel.fromJson(profileMap);
    } catch (e) {
      // Silently fail - will fetch from API instead
      return null;
    }
  }

  /// Clear user profile data from SharedPreferences
  Future<void> clearProfile() async {
    try {
      await _ensureInitialized();
      if (_prefs == null) {
        return;
      }
      
      await _prefs!.remove(_profileKey);
      if (kDebugMode) {
        debugPrint('✅ User profile cache cleared');
      }
    } catch (e) {
      // Silently fail - cache clearing is optional
    }
  }
}
