import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

import '../widgets/dialogs/status_dialog.dart';

class LocationPermissionHelper {
  static Future<bool> ensureLocationReady(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return false;
      StatusDialog.showWarning(
        context: context,
        title: 'เปิดบริการตำแหน่ง',
        message: 'กรุณาเปิด Location Services เพื่อใช้งานตำแหน่งปัจจุบัน',
      );
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!context.mounted) return false;
      StatusDialog.showWarning(
        context: context,
        title: 'ไม่ได้รับอนุญาต',
        message: 'กรุณาอนุญาตการเข้าถึงตำแหน่งเพื่อใช้งานฟีเจอร์นี้',
      );
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return false;
      final open = await StatusDialog.showConfirmation(
        context: context,
        title: 'ต้องอนุญาตตำแหน่ง',
        message: 'คุณปิดสิทธิ์ตำแหน่งถาวร กรุณาไปที่การตั้งค่าเพื่อเปิดสิทธิ์',
        confirmText: 'ไปที่ตั้งค่า',
        cancelText: 'ยกเลิก',
      );
      if (open) {
        await Geolocator.openAppSettings();
      }
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentPosition(BuildContext context) async {
    final ok = await ensureLocationReady(context);
    if (!ok) return null;
    return Geolocator.getCurrentPosition();
  }
}
