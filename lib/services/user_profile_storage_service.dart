import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/models/user_profile_model.dart';

/// Service for storing and retrieving user profile data from Secure Storage
class UserProfileStorageService {
  static final UserProfileStorageService _instance =
      UserProfileStorageService._internal();
  factory UserProfileStorageService() => _instance;
  UserProfileStorageService._internal();

  static const String _profileKey = 'user_profile_data';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Save user profile data to Secure Storage
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      final profileJson = jsonEncode(profile.toJson());
      await _storage.write(key: _profileKey, value: profileJson);
      if (kDebugMode) {
        debugPrint('✅ User profile cached in Secure Storage');
      }
    } catch (e) {
      debugPrint('❌ Error caching user profile: $e');
    }
  }

  /// Get user profile data from Secure Storage
  Future<UserProfileModel?> getProfile() async {
    try {
      final profileJson = await _storage.read(key: _profileKey);
      if (profileJson == null) return null;
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserProfileModel.fromJson(profileMap);
    } catch (e) {
      debugPrint('❌ Error reading user profile: $e');
      return null;
    }
  }

  /// Clear user profile data from Secure Storage
  Future<void> clearProfile() async {
    try {
      await _storage.delete(key: _profileKey);
      if (kDebugMode) {
        debugPrint('✅ User profile cache cleared');
      }
    } catch (e) {
      debugPrint('❌ Error clearing user profile cache: $e');
    }
  }
}
