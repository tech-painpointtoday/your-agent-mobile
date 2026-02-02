import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';

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
      await AppConfirmationBottomSheet.show(
        context: context,
        title: 'ต้องอนุญาตตำแหน่ง',
        description: 'คุณปิดสิทธิ์ตำแหน่งถาวร กรุณาไปที่การตั้งค่าเพื่อเปิดสิทธิ์',
        confirmLabel: 'ไปที่ตั้งค่า',
        cancelLabel: 'ยกเลิก',
        style: ConfirmationStyle.normal,
        onConfirm: () => Geolocator.openAppSettings(),
      );
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentPosition(BuildContext context) async {
    try {
      final ok = await ensureLocationReady(context);
      if (!ok) return null;
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      if (!context.mounted) return null;
      final message = e.toString();
      StatusDialog.showErrorDialog(
        context: context,
        title: 'เกิดข้อผิดพลาด',
        message: message.isNotEmpty ? message : 'ไม่สามารถรับตำแหน่งปัจจุบันได้',
      );
      return null;
    }
  }
}
