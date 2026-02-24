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
    await _requestNotificationPermission();
    _listenToFcmTokenRefresh();

    if (DependencyInjection.authRepository.isAuthenticated) {
      await registerDeviceAfterLogin();
    }
  }

  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  /// When FCM token is refreshed (e.g. by Firebase), save it and re-register so backend has the latest token.
  void _listenToFcmTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (newToken.isEmpty) return;
      debugPrint(
        'FCM token refreshed, updating storage and re-registering device',
      );
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

  Future<String?> _fetchFreshFcmToken() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken;
        for (int i = 0; i < 10; i++) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) break;
          debugPrint('Waiting for APNS Token... retry $i');
          await Future.delayed(Duration(seconds: 1));
        }

        if (apnsToken == null) {
          debugPrint('Failed to get APNS Token after 10 retries');
          return null;
        }
      }

      // ดึง FCM Token
      String? token = await FirebaseMessaging.instance.getToken();

      // บันทึกเก็บไว้เสมอเมื่อได้อันใหม่
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }
      return token;
    } catch (e) {
      debugPrint('Error fetching FCM token: $e');
      return null;
    }
  }

  Future<DeviceInfoModel> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId = '';
    String model = '';
    String osVersion = '';
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      model = androidInfo.model;
      osVersion = 'Android ${androidInfo.version.release}';
    } else {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_id';
      model = iosInfo.utsname.machine;
      osVersion = 'iOS ${iosInfo.systemVersion}';
    }

    // ส่วนของ Token: พยายามดึงใหม่ถ้าในเครื่องไม่มี
    String fcmToken = await getCachedFcmToken() ?? '';
    if (fcmToken.isEmpty) {
      fcmToken = await _fetchFreshFcmToken() ?? '';
    }

    _cachedInfo = DeviceInfoModel(
      token: fcmToken,
      deviceId: deviceId,
      platform: Platform.isAndroid ? 'android' : 'ios',
      appVersion: packageInfo.version,
      deviceModel: model,
      deviceOsVersion: osVersion,
    );

    return _cachedInfo!;
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

      final authRepo = DependencyInjection.authRepository;
      final user = authRepo.currentUser;

      if (user != null &&
          user.deviceTokens != null &&
          user.deviceTokens!.contains(info.token)) {
        debugPrint(
          'Device token already registered on server. Skipping API call.',
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
