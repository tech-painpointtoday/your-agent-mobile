import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/entities/device_info_model.dart';
import '../di/dependency_injection.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  static const String _deviceInfoKey = 'cached_device_info';
  DeviceInfoModel? _cachedInfo;

  DeviceInfoModel? get cachedInfo => _cachedInfo;

  Future<void> init() async {
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_deviceInfoKey);
    if (jsonString != null) {
      // Simple parsing, could use jsonDecode if complex
      // For now, we'll just re-capture to ensure freshness if not found or on Setiap boot
    }
  }

  Future<DeviceInfoModel> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId = '';
    String model = '';
    String osVersion = '';
    String platform = Platform.isAndroid ? 'android' : 'ios';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      model = androidInfo.model;
      osVersion = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_id';
      model = iosInfo.utsname.machine;
      osVersion = 'iOS ${iosInfo.systemVersion}';
    }

    // Get FCM Token
    String fcmToken = '';
    try {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    _cachedInfo = DeviceInfoModel(
      token: fcmToken,
      deviceId: deviceId,
      platform: platform,
      appVersion: packageInfo.version,
      deviceModel: model,
      deviceOsVersion: osVersion,
    );

    await _saveToPrefs();
    return _cachedInfo!;
  }

  Future<void> _saveToPrefs() async {
    if (_cachedInfo == null) return;
    final prefs = await SharedPreferences.getInstance();
    // We can store individual fields or a JSON string.
    // Given the requirement "save device info in sharepref", we'll store salient parts.
    await prefs.setString('device_id', _cachedInfo!.deviceId);
    await prefs.setString('fcm_token', _cachedInfo!.token);
  }

  Future<void> registerDevice() async {
    try {
      final info = await getDeviceInfo();
      // If FCM token is not yet available, skip registration to avoid
      // unauthorized (401) errors that can trigger a global logout.
      if (info.token.isEmpty) {
        debugPrint(
          'Skipping device registration: FCM token is empty (APNS token not ready yet).',
        );
        return;
      }

      await DependencyInjection.authApiService.registerDeviceToken(info);
      debugPrint('Device registered successfully');
    } catch (e) {
      debugPrint('Failed to register device: $e');
    }
  }
}
