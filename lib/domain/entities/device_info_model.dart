import 'package:equatable/equatable.dart';

class DeviceInfoModel extends Equatable {
  final String token;
  final String deviceId;
  final String platform;
  final String appVersion;
  final String deviceModel;
  final String deviceOsVersion;

  const DeviceInfoModel({
    required this.token,
    required this.deviceId,
    required this.platform,
    required this.appVersion,
    required this.deviceModel,
    required this.deviceOsVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'device_id': deviceId,
      'platform': platform,
      'app_version': appVersion,
      'device_model': deviceModel,
      'device_os_version': deviceOsVersion,
    };
  }

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      token: json['token'] as String,
      deviceId: json['device_id'] as String,
      platform: json['platform'] as String,
      appVersion: json['app_version'] as String,
      deviceModel: json['device_model'] as String,
      deviceOsVersion: json['device_os_version'] as String,
    );
  }

  @override
  List<Object?> get props => [
    token,
    deviceId,
    platform,
    appVersion,
    deviceModel,
    deviceOsVersion,
  ];
}
