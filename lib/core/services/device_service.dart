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
    _listenToFcmTokenRefresh();
  }

  /// When FCM token is refreshed (e.g. by Firebase), save it and re-register so backend has the latest token.
  void _listenToFcmTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (newToken.isEmpty) return;
      debugPrint('FCM token refreshed, updating storage and re-registering device');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', newToken);
      if (_cachedInfo != null) {
        _cachedInfo = DeviceInfoModel(
          token: newToken,
          deviceId: _cachedInfo!.deviceId,
          platform: _cachedInfo!.platform,
          appVersion: _cachedInfo!.appVersion,
          deviceModel: _cachedInfo!.deviceModel,
          deviceOsVersion: _cachedInfo!.deviceOsVersion,
        );
      }
      if (DependencyInjection.authRepository.isAuthenticated) {
        await registerDevice();
      }
    });
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_deviceInfoKey);
    if (jsonString != null) {
      // Simple parsing, could use jsonDecode if complex
      // For now, we'll just re-capture to ensure freshness if not found or on Setiap boot
    }
  }

  /// Returns cached FCM token from prefs, or null if never saved.
  Future<String?> getCachedFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Ensures we have an FCM token: use cached if present, otherwise fetch from Firebase and save.
  Future<String> ensureFcmToken() async {
    final cached = await getCachedFcmToken();
    if (cached != null && cached.isNotEmpty) return cached;
    final info = await getDeviceInfo();
    return info.token;
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

    // Use cached FCM token if we have it; otherwise fetch and save
    String fcmToken = '';
    final prefs = await SharedPreferences.getInstance();
    fcmToken = prefs.getString('fcm_token') ?? '';
    debugPrint('fcmToken: $fcmToken');
    if (fcmToken.isEmpty) {
      try {
        if (Platform.isIOS) {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            await Future<void>.delayed(const Duration(seconds: 3));
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          }
          if (apnsToken == null) {
            debugPrint('APNS token is still null. Check your Xcode setup.');
          }
        }
        fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      } catch (e) {
        debugPrint('Error getting FCM token: $e');
      }
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

  /// Call after login: ensures FCM token (fetches and saves if missing), then registers device.
  Future<void> registerDeviceAfterLogin() async {
    try {
      await ensureFcmToken();
      await registerDevice();
    } catch (e) {
      debugPrint('registerDeviceAfterLogin: $e');
    }
  }

  Future<void> registerDevice() async {
    try {
      final info = await getDeviceInfo();
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
